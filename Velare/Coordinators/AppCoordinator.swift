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

    var localizedName: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .capture: return "Capture"
        case .setting: return "Settings"
        case .permission: return "Permissions"
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

@MainActor
@Observable
final class AppCoordinator {
    var selectedRoute: AppRoute?

    let permissionService = PermissionService()
    let settingService = SettingService()
    let systemMonitorService = SystemMonitorService()
    let windowDiscoveryService = WindowDiscoveryService()

    private(set) var isLoading = true

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
