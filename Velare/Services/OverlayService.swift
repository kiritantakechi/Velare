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
    private(set) var texture: MTLTexture?
    private(set) var isTracking: Bool = false

    private var overlayWindow: NSWindow?
    private var targetFrame: CGRect = .zero
    private var trackingTask: Task<Void, Never>?

    func update(texture: MTLTexture) {
        self.texture = texture
    }

    func setWindow(_ window: NSWindow) {
        overlayWindow = window
        configureWindow()
    }

    func startTracking(window: WindowInfo) {
        guard trackingTask == nil else { return }
        isTracking = true

        trackingTask = Task {
            while !Task.isCancelled {
                // 如果目标窗口的 frame 变化了，就更新覆盖窗口的 frame
                if window.window.frame != self.targetFrame {
                    self.targetFrame = window.window.frame
                    self.overlayWindow?.setFrame(self.targetFrame, display: true, animate: false)
                }

                do {
                    // 每秒检查 60 次，以保证流畅跟随
                    try await Task.sleep(for: .seconds(1.0 / 60.0))
                } catch {
                    break
                }
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
    }
}
