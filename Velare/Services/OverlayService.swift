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
    private let windowObserverService: WindowObserverService
    
    private var overlayWindow: NSWindow?
    private var targetFrame: CGRect = .zero
    private var trackingTask: Task<Void, Never>?
    
    private(set) var videoFrame: VideoFrame?
    
    private(set) var isTracking: Bool = false
    private(set) var isWindowConfigured: Bool = false
    
    init(windowDiscoveryService: WindowDiscoveryService, windowObserverService: WindowObserverService) {
        self.windowDiscoveryService = windowDiscoveryService
        self.windowObserverService = windowObserverService
    }
    
    func update(videoFrame: consuming VideoFrame) {
        // print("🔄 [OverlayService] 纹理已更新 \(videoFrame.texture)")
        self.videoFrame = consume videoFrame
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
                    1.0 / 60.0, // 最快 60Hz 检测
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
        guard isTracking, trackingTask != nil else { return }
        isTracking = false
        
        trackingTask?.cancel()
        trackingTask = nil
        videoFrame = nil // 清理纹理
    }
    
    private func configureWindow() {
        guard !isWindowConfigured, let window = overlayWindow else { return }
        isWindowConfigured = false
        defer { isWindowConfigured = true }
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver // 让窗口保持在非常高的层级
        window.ignoresMouseEvents = true // 忽略鼠标事件，实现“点击穿透”
        window.hasShadow = false
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}

// import SwiftUI
// internal import ScreenCaptureKit
//
// @Observable
// final class OverlayService {
//    private let windowDiscoveryService: WindowDiscoveryService
//    private let windowObserverService: WindowObserverService
//
//    private var overlayWindow: NSWindow?
//    private var targetWindowID: CGWindowID?
//    private var trackingSubscriptionID: UUID?
//
//    private var targetFrame: CGRect = .zero
//
//    private(set) var texture: (any MTLTexture)?
//
//    private(set) var isTracking: Bool = false
//    private(set) var isWindowConfigured: Bool = false
//
//    init(windowDiscoveryService: WindowDiscoveryService, windowObserverService: WindowObserverService) {
//        self.windowDiscoveryService = windowDiscoveryService
//        self.windowObserverService = windowObserverService
//    }
//
//    func update(texture: consuming any MTLTexture) {
//        self.texture = consume texture
//        // print("🔄 [OverlayService] 纹理已更新")
//    }
//
//    func setWindow(_ window: consuming NSWindow) {
//        guard window !== overlayWindow else { return }
//
//        overlayWindow = consume window
//
//        configureWindow()
//    }
//
//    func startTracking(window: SCWindow) {
//        guard !isTracking else { return }
//        isTracking = true
//        let windowID = window.windowID
//        targetWindowID = windowID
//
//        trackingSubscriptionID = windowObserverService.subscribe { [weak self] event in
//            guard let self = self else { return }
//
//            switch event {
//            case .moved(let id), .resized(let id):
//                guard id == windowID else { return }
//                self.updateFrame(for: id)
//            case .closed(let id):
//                guard id == windowID else { return }
//                self.stopTracking()
//            default: break
//            }
//        }
//
//        updateFrame(for: windowID)
//    }
//
//    func stopTracking() {
//        guard isTracking else { return }
//        isTracking = false
//
//        if let subID = trackingSubscriptionID {
//            windowObserverService.unsubscribe(subID)
//            trackingSubscriptionID = nil
//        }
//
//        texture = nil // 清理纹理
//    }
//
//    private func updateFrame(for windowID: CGWindowID) {
//        guard let frame = findWindowFrame(by: windowID), frame != targetFrame else { return }
//        targetFrame = frame
//        overlayWindow?.setFrame(frame, display: true, animate: false)
//        if let metalLayer = overlayWindow?.contentView?.layer as? CAMetalLayer,
//           let screen = overlayWindow?.screen
//        {
//            metalLayer.drawableSize = CGSize(
//                width: frame.width * screen.backingScaleFactor,
//                height: frame.height * screen.backingScaleFactor
//            )
//        }
//        print("📍 [OverlayService] 更新 Frame 至: \(frame)")
//    }
//
//    private func findWindowFrame(by windowID: CGWindowID) -> CGRect? {
//        guard let frame = windowDiscoveryService.findWindowFrame(by: windowID) else {
//            return nil
//        }
//        return frame
//    }
//
//    private func configureWindow() {
//        guard !isWindowConfigured, let window = overlayWindow else { return }
//        isWindowConfigured = false
//        defer { isWindowConfigured = true }
//
//        window.isOpaque = false
//        window.backgroundColor = .clear
//        window.level = .screenSaver // 让窗口保持在非常高的层级
//        window.ignoresMouseEvents = true // 忽略鼠标事件，实现“点击穿透”
//        window.hasShadow = false
//        window.standardWindowButton(.closeButton)?.isHidden = true
//        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
//        window.standardWindowButton(.zoomButton)?.isHidden = true
//
////        window.contentView?.wantsLayer = true
////        if window.contentView?.layer == nil {
////            window.contentView?.layer = CAMetalLayer()
////        }
////
////        window.makeKeyAndOrderFront(nil)
////
////        // 延迟第一次更新
////        DispatchQueue.main.async {
////            if let id = self.targetWindowID {
////                self.updateFrame(for: id)
////            }
////        }
//    }
// }
