//
//  CaptureService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/01.
//

import SwiftUI
internal import ScreenCaptureKit

@Observable
final class CaptureService: NSObject {
    private(set) var isCapturing: Bool = false
    private(set) var frameStream: AsyncStream<CMSampleBuffer>?
    private var streamContinuation: AsyncStream<CMSampleBuffer>.Continuation?
    private var streamOutputHandler: StreamOutputHandler?

    private var capturePipelineTask: Task<Void, Never>?
    private var scStream: SCStream?

    private let cacheService: CacheService
    private let overlayService: OverlayService
    private let processingService: ProcessingService
    private let settingService: SettingService
    private let windowDiscoveryService: WindowDiscoveryService

    init(cacheService: CacheService, overlayService: OverlayService, processingService: ProcessingService, settingService: SettingService, windowDiscoveryService: WindowDiscoveryService) {
        self.cacheService = cacheService
        self.overlayService = overlayService
        self.processingService = processingService
        self.settingService = settingService
        self.windowDiscoveryService = windowDiscoveryService
        super.init()
    }

    func startCapture(for window: SCWindow) {
        // Fix: If already capturing, do nothing.
        guard !isCapturing else {
            print("Capture is already in progress.")
            return
        }
        // Fix: Set state synchronously to prevent race conditions.
        isCapturing = true

        capturePipelineTask = Task {
            do {
                // 1. Command OverlayService to start tracking.
                self.overlayService.startTracking(window: window)

                // 2. Start the stream and get the data flow.
                try await self.startStream(for: window)

                // 3. Asynchronously loop through each frame.
                if let stream = self.frameStream {
                    for await sampleBuffer in stream {
                        try Task.checkCancellation()

                        guard let videoFrame = VideoFrame(from: sampleBuffer, textureCache: self.cacheService.textureCache) else {
                            continue
                        }

                        let processedFrame = try await self.processingService.process(videoFrame)
                        self.overlayService.update(texture: processedFrame.texture)
                    }
                }
            } catch is CancellationError {
                print("Capture pipeline was cancelled.")
            } catch {
                print("Capture pipeline stopped due to error: \(error)")
            }

            // --- Cleanup ---
            await self.stopStream()
            self.overlayService.stopTracking()
            self.isCapturing = false
            self.capturePipelineTask = nil
            print("Capture pipeline and resources cleaned up.")
        }
    }

    func stopCapture() {
        // If not capturing, do nothing.
        guard isCapturing else { return }

        // Cancel the main pipeline task.
        // The cleanup is handled within the Task's completion block.
        capturePipelineTask?.cancel()
    }

    private func startStream(for window: SCWindow) async throws {
        let filter = SCContentFilter(desktopIndependentWindow: window)
        let config = SCStreamConfiguration()

        guard let liveFrame = windowDiscoveryService.findWindowFrame(by: window.windowID) else {
            throw NSError(domain: "CaptureService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find window frame."])
        }

        config.width = Int(liveFrame.width) << 1
        config.height = Int(liveFrame.height) << 1
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(settingService.inputFramerate))
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.queueDepth = settingService.inputFramerate >> 2

        // 1. Create the AsyncStream and its continuation.
        let (stream, continuation) = AsyncStream.makeStream(of: CMSampleBuffer.self)
        frameStream = stream

        // 2. Create the dedicated stream output handler.
        streamOutputHandler = StreamOutputHandler(continuation: continuation)

        // 3. Set up the SCStream.
        scStream = SCStream(filter: filter, configuration: config, delegate: nil)
        try scStream?.addStreamOutput(streamOutputHandler!, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
        try await scStream?.startCapture()
    }

    private func stopStream() async {
        try? await scStream?.stopCapture()
        streamOutputHandler?.continuation.finish()
        scStream = nil
        frameStream = nil
        streamOutputHandler = nil
    }
}

// A dedicated, non-actor-isolated class to handle background callbacks from SCStream.
private final class StreamOutputHandler: NSObject, SCStreamOutput {
    let continuation: AsyncStream<CMSampleBuffer>.Continuation

    init(continuation: AsyncStream<CMSampleBuffer>.Continuation) {
        self.continuation = continuation
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid else { return }

        guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let attachments = attachmentsArray.first,
              let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
              let status = SCFrameStatus(rawValue: statusRawValue),
              status == .complete
        else {
            return
        }

        continuation.yield(sampleBuffer)
    }
}
