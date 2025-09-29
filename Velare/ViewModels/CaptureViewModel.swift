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

    var isRefreshing = false

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.windowDiscoveryService = coordinator.windowDiscoveryService
        refreshWindows()
    }

    func refreshWindows() {
        guard !isRefreshing else { return }

        isRefreshing = true

        Task {
            async let refreshTask: () = await windowDiscoveryService.refreshAvailableContent()
            async let sleepTask: () = (try? await Task.sleep(for: .seconds(0.1))) ?? ()

            _ = await (refreshTask, sleepTask)

            isRefreshing = false
        }
    }

    func clearSelection() {
        windowDiscoveryService.clearSelection()
    }
}
