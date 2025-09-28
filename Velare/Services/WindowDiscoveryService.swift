//
//  WindowDiscoveryService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import ScreenCaptureKit
import SwiftUI

@Observable
final class WindowDiscoveryService {
    private(set) var availableWindows: [WindowInfo] = []
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
        selectedWindowID = availableWindows.first { $0.id == windowID }?.id ?? windowID
    }

    func clearSelection() {
        selectedWindowID = nil
    }
}
