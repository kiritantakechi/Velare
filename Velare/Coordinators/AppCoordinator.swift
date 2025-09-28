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

enum AppState: Sendable {
    case loading
    case dashboard
    case capture
    case setting
    case permission
}

@MainActor
@Observable
final class AppCoordinator {
    private(set) var currentState: AppState = .loading
    var selectedRoute: AppRoute?

    func start() async {
        await checkPermissions()
    }

    private func checkPermissions() async {
        try? await Task.sleep(for: .seconds(1))
        currentState = .permission
        selectedRoute = .permission
    }

    func selectRoute(_ route: AppRoute) {
        selectedRoute = route
        switch route {
        case .dashboard: currentState = .dashboard
        case .capture: currentState = .capture
        case .setting: currentState = .setting
        case .permission: currentState = .permission
        }
    }

    func permissionsGranted() {
        currentState = .dashboard
        selectedRoute = .dashboard
    }

    let windowDiscoveryService = WindowDiscoveryService()
    
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel()
    }

    func makeCaptureViewModel() -> CaptureViewModel {
        CaptureViewModel(service: windowDiscoveryService)
    }
    
    func makePermissionViewModel() -> PermissionViewModel {
        PermissionViewModel()
    }
    
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel()
    }
}
