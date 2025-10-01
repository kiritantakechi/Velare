//
//  CaptureViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class CaptureViewModel {
    private let coordinator: AppCoordinator
    private let windowDiscoveryService: WindowDiscoveryService

    var availableWindows: [WindowInfo] { windowDiscoveryService.availableWindows }

    var selectedWindowID: CGWindowID? {
        get {
            windowDiscoveryService.selectedWindowID
        }
        set {
            if let windowID = newValue {
                windowDiscoveryService.selectWindow(by: windowID)
            } else {
                windowDiscoveryService.clearSelection()
            }
        }
    }

    var isCapturing: Bool = false
    var isRefreshing: Bool = false

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.windowDiscoveryService = coordinator.windowDiscoveryService
        refreshWindows()
    }

    func toggleCapture() {
        isCapturing.toggle()

        if isCapturing {
            // 在这里开始捕获的逻辑...
            print("开始捕获窗口: \(selectedWindowID ?? 0)")
        } else {
            // 在这里停止捕获的逻辑...
            print("停止捕获。")
        }
    }

    func refreshWindows(interval: TimeInterval = 0.1) {
        guard !isRefreshing else { return }

        isRefreshing = true

        Task {
            async let refreshTask: () = await windowDiscoveryService.refreshAvailableContent()
            async let sleepTask: () = (try? await Task.sleep(for: .seconds(interval))) ?? ()

            _ = await (refreshTask, sleepTask)

            isRefreshing = false
        }
    }

    func clearSelection() {
        windowDiscoveryService.clearSelection()
    }
}
