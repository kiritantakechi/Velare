//
//  WindowDiscoveryService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI
internal import ScreenCaptureKit

@Observable
final class WindowDiscoveryService {
    private(set) var availableWindows: [SCWindow] = []
    private(set) var selectedWindow: SCWindow?

    private(set) var isRefreshing: Bool = false

    init() {}

    func refreshAvailableContent() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let content = try await SCShareableContent.current
            let validWindows = content.windows.filter(isValidWindow)
            if availableWindows != validWindows { availableWindows = validWindows }
        } catch {
            print("Failed to get shareable content: \(error.localizedDescription)")
        }
    }

    func findWindowFrame(by windowID: CGWindowID) -> CGRect? {
        // 使用 CoreGraphics 的 API 来获取窗口信息
        // .optionIncludingWindow 表示我们只查询这一个窗口
        guard let windowListInfo = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: AnyObject]] else {
            return nil
        }

        // 确保我们真的找到了这个窗口的信息
        guard let windowInfo = windowListInfo.first else {
            return nil
        }

        // 从返回的字典中解析出窗口的边界信息
        guard let cgBounds = windowInfo[kCGWindowBounds as String] as? [String: CGFloat],
              let frame = CGRect(dictionaryRepresentation: cgBounds as CFDictionary)
        else {
            return nil
        }

        print("🔎 [WDS] CoreGraphics 原始 Frame: \(frame)")

        // ！！！关键的坐标系转换！！！
        // CoreGraphics 的坐标原点 (0,0) 在屏幕左上角
        // AppKit/SwiftUI 的坐标原点 (0,0) 在屏幕左下角
        // 我们需要将 y 坐标进行转换
        guard let screen = NSScreen.main else { return frame } // 如果获取不到屏幕，返回原始 frame
        let screenHeight = screen.frame.height

        let convertedFrame = CGRect(
            x: frame.origin.x,
            y: screenHeight - frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )

        print("🗺️ [WDS] 转换后 AppKit Frame: \(convertedFrame)")

        return convertedFrame
    }

    func selectWindow(by windowID: CGWindowID) {
        selectedWindow = availableWindows.first { $0.windowID == windowID }
    }

    func clearSelection() {
        selectedWindow = nil
    }

    private func isValidWindow(_ window: SCWindow) -> Bool {
        // 条件 1: 必须有一个所属的应用程序
        guard let app = window.owningApplication else { return false }

        // 条件 2: 必须不是我们自己的应用窗口
        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return false }

        // 条件 3: 必须是标准的、可见的窗口层级 (layer 0)
        guard window.windowLayer == 0 else { return false }

        // 条件 4: 窗口必须在屏幕上（即没有被最小化）
        guard window.isOnScreen else { return false }

        // 条件 5: 窗口必须有一个非空的标题
        guard let title = window.title, !title.isEmpty else { return false }

        // 条件 6: 窗口尺寸必须大于一个合理的阈值
        guard window.frame.width > 100, window.frame.height > 100 else { return false }

        return true
    }
}
