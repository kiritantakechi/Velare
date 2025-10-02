//
//  CaptureViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI
internal import ScreenCaptureKit

@Observable
final class CaptureViewModel {
    private let coordinator: AppCoordinator
    private let captureService: CaptureService
    private let windowDiscoveryService: WindowDiscoveryService

    var availableWindows: [SCWindow] { windowDiscoveryService.availableWindows }

    var selectedWindow: SCWindow? { windowDiscoveryService.selectedWindow }

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

    var isCapturing: Bool { captureService.isCapturing }

    var isRefreshing: Bool = false

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.captureService = coordinator.captureService
        self.windowDiscoveryService = coordinator.windowDiscoveryService

        guard !isCapturing else { return }

        refreshWindows()
    }

    func toggleCapture() {
        if captureService.isCapturing {
            captureService.stopCapture()
        } else {
            guard let window = selectedWindow else { return }
            captureService.startCapture(for: window)
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
