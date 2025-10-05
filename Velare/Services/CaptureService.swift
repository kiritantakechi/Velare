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
    private let gpuPool: GPUPool

    private let overlayService: OverlayService
    private let processingService: ProcessingService
    private let settingService: SettingService
    private let windowDiscoveryService: WindowDiscoveryService

    private var scStream: SCStream?
    private var frameStream: AsyncStream<CMSampleBuffer>?
    private var streamContinuation: AsyncStream<CMSampleBuffer>.Continuation?
    private var streamOutputHandler: StreamOutputHandler?

    private var capturePipelineTask: Task<Void, Never>?

    private(set) var isCapturing: Bool = false

    init(gpuPool: GPUPool, overlayService: OverlayService, processingService: ProcessingService, settingService: SettingService, windowDiscoveryService: WindowDiscoveryService) {
        self.gpuPool = gpuPool

        self.overlayService = overlayService
        self.processingService = processingService
        self.settingService = settingService
        self.windowDiscoveryService = windowDiscoveryService

        super.init()
    }

    func startCapture(for window: SCWindow) {
        guard !isCapturing else {
            print("Capture is already in progress.")
            return
        }
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

                        let ctx = self.gpuPool.acquireContext()

                        // 2. 创建 VideoFrame
                        guard let frame = VideoFrame(from: sampleBuffer, using: ctx) else { continue }

                        // 3. 异步处理
                        let processedTexture = try await self.processingService.process(frame)

                        // 7. 更新 OverlayService
                        self.overlayService.update(texture: processedTexture.texture)
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

        continuation.yield(sampleBuffer)
    }
}
