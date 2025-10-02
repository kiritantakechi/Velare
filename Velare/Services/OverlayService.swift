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

    private(set) var texture: MTLTexture?
    private(set) var isTracking: Bool = false

    private var overlayWindow: NSWindow?
    private var targetFrame: CGRect = .zero
    private var trackingTask: Task<Void, Never>?

    init(windowDiscoveryService: WindowDiscoveryService) {
        self.windowDiscoveryService = windowDiscoveryService
    }

    func update(texture: MTLTexture) {
        self.texture = texture
        print("🔄 [OverlayService] 纹理已更新")
    }

    func setWindow(_ window: NSWindow) {
        overlayWindow = window
        configureWindow()
    }

    func startTracking(window: SCWindow) {
        guard trackingTask == nil else { return }
        isTracking = true

        trackingTask = Task {
            while !Task.isCancelled {
                print("👁️ [OverlayService] 正在运行追踪循环...")
                guard let liveFrame = self.windowDiscoveryService.findWindowFrame(by: window.windowID) else { break }
                // 如果目标窗口的 frame 变化了，就更新覆盖窗口的 frame
                guard liveFrame != self.targetFrame else { break }

                self.targetFrame = liveFrame
                self.overlayWindow?.setFrame(self.targetFrame, display: true, animate: false)

                print("📍 [OverlayService] 目标窗口移动，更新 Frame 至: \(self.targetFrame)")

                do {
                    // 每秒检查 60 次，以保证流畅跟随
                    try await Task.sleep(for: .seconds(1.0 / 60.0))
                } catch {
                    break
                }
            }

            await MainActor.run {
                self.stopTracking()
            }
        }
    }

    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        isTracking = false
        texture = nil // 清理纹理
    }

    private func configureWindow() {
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
