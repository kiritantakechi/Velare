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
    private unowned let coordinator: AppCoordinator
    private unowned let captureService: CaptureService
    private unowned let windowDiscoveryService: WindowDiscoveryService

    // 等待 Swift 6.3 对 Span 类型指定生命周期的支持
    var availableWindows: [SCWindow] { windowDiscoveryService.availableWindows }
    var selectedWindow: SCWindow? { windowDiscoveryService.selectedWindow }
    var selectedWindowID: CGWindowID? {
        get { windowDiscoveryService.selectedWindow?.windowID }
        set {
            if let windowID = newValue {
                windowDiscoveryService.selectWindow(by: windowID)
            } else {
                windowDiscoveryService.clearSelection()
            }
        }
    }

    var isCapturing: Bool { captureService.isCapturing }
    var isRefreshing: Bool { windowDiscoveryService.isRefreshing }

    init(coordinator: consuming AppCoordinator) {
        self.captureService = coordinator.captureService
        self.windowDiscoveryService = coordinator.windowDiscoveryService
        self.coordinator = consume coordinator
    }

    func onAppear() {
        guard !isCapturing else { return }

        refreshWindows()
    }

    func startCapture() {
        guard let window = selectedWindow else { return }

        captureService.startCapture(for: window)
    }

    func stopCapture() {
        captureService.stopCapture()
    }

    func refreshWindows(interval: TimeInterval = 0.1) {
        Task {
            async let refreshTask: () = await windowDiscoveryService.refreshAvailableContent()
            async let sleepTask: () = (try? await Task.sleep(for: .seconds(interval))) ?? ()

            return await (refreshTask, sleepTask)
        }
    }

    func clearSelection() {
        windowDiscoveryService.clearSelection()
    }
}
