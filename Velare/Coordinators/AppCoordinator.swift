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

    let captureService: CaptureService
    let permissionService: PermissionService
    let processingService: ProcessingService
    let settingService: SettingService
    let systemMonitorService: SystemMonitorService
    let windowDiscoveryService: WindowDiscoveryService

    private(set) var isLoading = true

    init() {
        settingService = SettingService()

        captureService = CaptureService()
        permissionService = PermissionService()
        processingService = ProcessingService(setting: settingService)
        systemMonitorService = SystemMonitorService()
        windowDiscoveryService = WindowDiscoveryService()
    }

    func start() async {
        await checkPermissions()
        updateSystemMonitor()

        isLoading = false
    }

    private func checkPermissions() async {
        permissionService.checkPermissions()

        if permissionService.isScreenCapturePermissionGranted {
            permissionsGranted()
        }
        else {
            permissionsDenied()
        }
    }

    private func updateSystemMonitor() {
        systemMonitorService.updateMonitoring()
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
