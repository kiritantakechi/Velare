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

    private(set) var texture: (any MTLTexture)?
    private(set) var isTracking: Bool = false

    private var overlayWindow: NSWindow?
    private var targetFrame: CGRect = .zero
    private var trackingTask: Task<Void, Never>?

    init(windowDiscoveryService: WindowDiscoveryService) {
        self.windowDiscoveryService = windowDiscoveryService
    }

    func update(texture: consuming any MTLTexture) {
        self.texture = texture
        print("🔄 [OverlayService] 纹理已更新")
    }

    func setWindow(_ window: NSWindow) {
        guard window !== overlayWindow else { return }
        
        overlayWindow = window
        configureWindow()
    }

    func startTracking(window: SCWindow) {
        guard trackingTask == nil else { return }
        isTracking = true

        trackingTask = Task {
            while !Task.isCancelled {
                if let liveFrame = self.windowDiscoveryService.findWindowFrame(by: window.windowID) {
                    if liveFrame != self.targetFrame {
                        self.targetFrame = liveFrame
                        self.overlayWindow?.setFrame(self.targetFrame, display: true, animate: false)
                        print("📍 [OverlayService] 目标窗口移动，更新 Frame 至: \(self.targetFrame)")
                    }
                } else {
                    // Window not found, break the loop.
                    break
                }

                do {
                    try await Task.sleep(for: .seconds(1.0 / 60.0))
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
