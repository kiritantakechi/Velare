//
//  CaptureService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/01.
//

import ScreenCaptureKit
import SwiftUI

@Observable
final class CaptureService: NSObject {
    private(set) var isCapturing: Bool = false
    private(set) var frameStream: AsyncStream<CMSampleBuffer>?
    private var streamContinuation: AsyncStream<CMSampleBuffer>.Continuation?

    private var scStream: SCStream?

    override init() {
        super.init()
    }

    func toggleCapture(for window: WindowInfo) {
        isCapturing.toggle()

        if isCapturing {
            // 在这里开始捕获的逻辑...
            print("开始捕获窗口: \(window.id)")
        } else {
            // 在这里停止捕获的逻辑...
            print("停止捕获。")
        }
    }

    private func startCapture(for window: WindowInfo, setting: SettingService) async throws {
        // 创建 AsyncStream
        frameStream = AsyncStream { continuation in
            self.streamContinuation = continuation
        }

        let filter = SCContentFilter(desktopIndependentWindow: window.window)
        let config = SCStreamConfiguration()
        config.width = Int(window.window.frame.width * 2) // 示例：以 Retina 分辨率捕获
        config.height = Int(window.window.frame.height * 2)
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(setting.inputFramerate))
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
        // 当收到新的帧时，将其推送到 AsyncStream 中
        streamContinuation?.yield(sampleBuffer)
    }
}
