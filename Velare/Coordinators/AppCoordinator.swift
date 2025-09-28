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

    func start() async {
        await checkPermissions()
    }

    private func checkPermissions() async {
        try? await Task.sleep(for: .seconds(1))
        currentStatus = .permission
        selectedRoute = .permission
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

    let permissionService = PermissionService()
    let windowDiscoveryService = WindowDiscoveryService()
    
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel()
    }

    func makeCaptureViewModel() -> CaptureViewModel {
        CaptureViewModel(windowDiscoveryService: windowDiscoveryService)
    }
    
    func makePermissionViewModel() -> PermissionViewModel {
        PermissionViewModel(permissionService: permissionService)
    }
    
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel()
    }
}
