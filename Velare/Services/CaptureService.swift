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

    // 待优化
    func toggleCapture(for window: SCWindow) {
        if isCapturing {
            // 如果正在捕获，则取消任务以停止
            capturePipelineTask?.cancel()
            return
        }

        capturePipelineTask = Task {
            do {
                isCapturing = true

                // 1. 命令 OverlayService 开始追踪
                overlayService.startTracking(window: window)

                // 2. 开始捕获并获取数据流
                try await self.startCapture(for: window)

                // 3. 异步循环处理每一帧
                if let stream = self.frameStream {
                    for await sampleBuffer in stream {
                        try Task.checkCancellation()

                        guard let videoFrame = VideoFrame(from: sampleBuffer, textureCache: self.cacheService.textureCache) else {
                            continue
                        }

                        let processedFrame = try await self.processingService.process(videoFrame)

                        print("➡️ [CaptureService] 帧处理完成，准备更新 Overlay")

                        self.overlayService.update(texture: processedFrame.texture)
                    }
                }
            } catch {
                print("捕获管线因错误或取消而停止: \(error)")
            }

            // 循环结束后（无论是正常结束还是被取消），执行清理
            await stopCapture()
            overlayService.stopTracking()
            isCapturing = false
            capturePipelineTask = nil
        }
    }

    private func startCapture(for window: SCWindow) async throws {
        // 创建 AsyncStream
        frameStream = AsyncStream { continuation in
            self.streamContinuation = continuation
        }

        let filter = SCContentFilter(desktopIndependentWindow: window)
        let config = SCStreamConfiguration()
        
        let liveFrame = windowDiscoveryService.findWindowFrame(by: window.windowID)
        
        config.width = Int(liveFrame!.width * 2) // 示例：以 Retina 分辨率捕获
        config.height = Int(liveFrame!.height * 2)
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(settingService.inputFramerate))
        config.pixelFormat = kCVPixelFormatType_32BGRA

        scStream = SCStream(filter: filter, configuration: config, delegate: self)
        try scStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
        try await scStream?.startCapture()
    }

    private func stopCapture() async {
        try? await scStream?.stopCapture()
        streamContinuation?.finish()
        scStream = nil
        frameStream = nil
    }
}

extension CaptureService: SCStreamDelegate, SCStreamOutput {
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard sampleBuffer.isValid else { return }

        guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let attachments = attachmentsArray.first
        else {
            return
        }

        // 2. 从附件中获取帧的状态
        // 只有当状态为 .complete 时，才是一个可以处理的完整帧
        guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
              let status = SCFrameStatus(rawValue: statusRawValue),
              status == .complete
        else {
            // 否则，静默地丢弃这个 buffer (例如，当窗口内容没有变化时，就会收到 .idle 状态的 buffer)
            return
        }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        print("✅ [CaptureService] 收到新帧，时间戳: \(timestamp.seconds)")

        streamContinuation?.yield(sampleBuffer)
    }
}
