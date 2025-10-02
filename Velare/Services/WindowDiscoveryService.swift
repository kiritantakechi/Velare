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
    private(set) var availableWindows: [WindowInfo] = []
    private(set) var selectedWindow: WindowInfo?
    private(set) var selectedWindowID: CGWindowID?

    func refreshAvailableContent() async {
        do {
            let content = try await SCShareableContent.current
            let validWindows = content.windows.map { WindowInfo(from: $0) }.filter { $0.isValid }

            if availableWindows != validWindows { availableWindows = validWindows }
        } catch {
            print("Failed to get shareable content: \(error.localizedDescription)")
        }
    }

    func selectWindow(by windowID: CGWindowID) {
        selectedWindow = availableWindows.first { $0.id == windowID }
        // 待优化
        selectedWindowID = selectedWindow?.id ?? windowID
    }

    func clearSelection() {
        selectedWindow = nil
        selectedWindowID = nil
    }
}
