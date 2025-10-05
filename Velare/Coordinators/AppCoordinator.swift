//
//  AppCoordinator.swift
//  Velare
//
//  Created by Kiritan on 2025/09/27.
//

import SwiftUI

enum AppRoute: String, CaseIterable, Hashable, Identifiable, Sendable {
    case dashboard
    case capture
    case setting
    case permission

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .dashboard: return "coordinator.route.dashboard"
        case .capture: return "coordinator.route.capture"
        case .setting: return "coordinator.route.setting"
        case .permission: return "coordinator.route.permission"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: return "chart.bar"
        case .capture: return "camera.viewfinder"
        case .setting: return "gear"
        case .permission: return "lock.shield"
        }
    }
}

@Observable
final class AppCoordinator {
    var selectedRoute: AppRoute?

    let gpuPool: GPUPool

    let captureService: CaptureService
    let overlayService: OverlayService
    let permissionService: PermissionService
    let processingService: ProcessingService
    let settingService: SettingService
    let systemMonitorService: SystemMonitorService
    let windowDiscoveryService: WindowDiscoveryService
    let windowObserverService: WindowObserverService

    private(set) var isLoading: Bool = false

    init() {
        settingService = SettingService()

        gpuPool = GPUPool(contextCount: 4)

        permissionService = PermissionService()
        systemMonitorService = SystemMonitorService()
        windowDiscoveryService = WindowDiscoveryService()
        windowObserverService = WindowObserverService()

        overlayService = OverlayService(windowDiscoveryService: windowDiscoveryService)
        processingService = ProcessingService(SettingService: settingService)
        captureService = CaptureService(gpuPool: gpuPool, overlayService: overlayService, processingService: processingService, settingService: settingService, windowDiscoveryService: windowDiscoveryService)
    }

    func start() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await checkPermissions()
    }

    private func checkPermissions() async {
        if permissionService.isAccessibilityPermissionGranted, permissionService.isScreenCapturePermissionGranted {
            permissionsGranted()
        }
        else {
            permissionsDenied()
        }
    }

    func selectRoute(_ route: AppRoute) {
        selectedRoute = route
    }

    func permissionsGranted() {
        selectedRoute = .dashboard
    }

    func permissionsDenied() {
        selectedRoute = .permission
    }
}
