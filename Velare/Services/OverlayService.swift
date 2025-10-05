//
//  OverlayService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI
internal import ScreenCaptureKit

@Observable
final class OverlayService {
    private let windowDiscoveryService: WindowDiscoveryService

    private var overlayWindow: NSWindow?
    private var targetFrame: CGRect = .zero
    private var trackingTask: Task<Void, Never>?

    private(set) var texture: (any MTLTexture)?

    private(set) var isTracking: Bool = false
    private(set) var isWindowConfigured: Bool = false

    init(windowDiscoveryService: WindowDiscoveryService) {
        self.windowDiscoveryService = windowDiscoveryService
    }

    func update(texture: consuming any MTLTexture) {
        self.texture = consume texture
        // print("🔄 [OverlayService] 纹理已更新")
    }

    func setWindow(_ window: consuming NSWindow) {
        guard window !== overlayWindow else { return }

        overlayWindow = consume window
        configureWindow()
    }

    func startTracking(window: SCWindow) {
        guard !isTracking, trackingTask == nil else { return }
        isTracking = true

        trackingTask = Task {
            var idleFrameCount = 0

            while !Task.isCancelled {
                if let liveFrame = self.windowDiscoveryService.findWindowFrame(by: window.windowID) {
                    if liveFrame != self.targetFrame {
                        self.targetFrame = liveFrame
                        self.overlayWindow?.setFrame(self.targetFrame, display: true, animate: false)
                        print("📍 [OverlayService] 目标窗口移动，更新 Frame 至: \(self.targetFrame)")

                        idleFrameCount = 0
                    } else {
                        idleFrameCount += 1
                    }
                } else {
                    // Window not found, break the loop.
                    break
                }
                let delay = max(
                    1.0 / 240.0, // 最快 240Hz 检测
                    min(0.25, pow(2.0, Double(idleFrameCount)) * (1.0 / 120.0))
                )
                do {
                    try await Task.sleep(for: .seconds(delay))
                } catch {
                    // Task was cancelled during sleep.
                    break
                }
            }

            // Cleanup when loop exits.
            self.stopTracking()
        }
    }

    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        isTracking = false
        texture = nil // 清理纹理
    }

    private func configureWindow() {
        guard !isWindowConfigured, overlayWindow != nil else { return }
        isWindowConfigured = false
        defer { isWindowConfigured = true }

        overlayWindow?.isOpaque = false
        overlayWindow?.backgroundColor = .clear
        overlayWindow?.level = .screenSaver // 让窗口保持在非常高的层级
        overlayWindow?.ignoresMouseEvents = true // 忽略鼠标事件，实现“点击穿透”
        overlayWindow?.hasShadow = false
        overlayWindow?.standardWindowButton(.closeButton)?.isHidden = true
        overlayWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        overlayWindow?.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
