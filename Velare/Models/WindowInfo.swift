//
//  WindowInfo.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

//import SwiftUI
//internal import ScreenCaptureKit
//
//struct WindowInfo: Hashable, Identifiable, Sendable {
//    let id: CGWindowID
//    let appName: String
//    let title: String
//    let isValid: Bool
//
//    init(from window: SCWindow) {
//        self.id = window.windowID
//        self.appName = window.owningApplication?.applicationName ?? "Unknown"
//        self.title = window.title ?? ""
//        self.isValid = WindowInfo.isValidWindow(window)
//    }
//
//    private static func isValidWindow(_ window: SCWindow) -> Bool {
//        // 条件 1: 必须有一个所属的应用程序
//        guard let app = window.owningApplication else { return false }
//
//        // 条件 2: 必须不是我们自己的应用窗口
//        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return false }
//
//        // 条件 3: 必须是标准的、可见的窗口层级 (layer 0)
//        guard window.windowLayer == 0 else { return false }
//
//        // 条件 4: 窗口必须在屏幕上（即没有被最小化）
//        guard window.isOnScreen else { return false }
//
//        // 条件 5: 窗口必须有一个非空的标题
//        guard let title = window.title, !title.isEmpty else { return false }
//
//        // 条件 6: 窗口尺寸必须大于一个合理的阈值
//        guard window.frame.width > 100, window.frame.height > 100 else { return false }
//
//        return true
//    }
//}
