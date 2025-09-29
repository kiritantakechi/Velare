//
//  AppCoordinator.swift
//  Velare
//
//  Created by Kiritan on 2025/09/27.
//

import SwiftUI

enum AppRoute: CaseIterable, Hashable, Identifiable, Sendable {
    var id: Self { self }

    case dashboard
    case capture
    case setting
    case permission

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

enum AppStatus: Sendable {
    case loading
    case dashboard
    case capture
    case setting
    case permission
}

@MainActor
@Observable
final class AppCoordinator {
    private(set) var currentStatus: AppStatus = .loading
    var selectedRoute: AppRoute?

    let permissionService = PermissionService()
    let windowDiscoveryService = WindowDiscoveryService()
    
    var isLoading: Bool { currentStatus == .loading }

    func start() async {
        await checkPermissions()
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

    func selectRoute(_ route: AppRoute) {
        selectedRoute = route
        switch route {
        case .dashboard: currentStatus = .dashboard
        case .capture: currentStatus = .capture
        case .setting: currentStatus = .setting
        case .permission: currentStatus = .permission
        }
    }

    func permissionsGranted() {
        currentStatus = .dashboard
        selectedRoute = .dashboard
    }

    func permissionsDenied() {
        currentStatus = .permission
        selectedRoute = .permission
    }
}
