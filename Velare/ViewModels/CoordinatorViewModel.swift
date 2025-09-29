//
//  CoordinatorViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

@Observable
final class CoordinatorViewModel {
    private let coordinator: AppCoordinator
    
    var currentStatus: AppStatus { coordinator.currentStatus }

    var selectedRoute: AppRoute? { get { coordinator.selectedRoute } set { coordinator.selectedRoute = newValue }}
    
    var isLoading: Bool { coordinator.isLoading }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func start() {
        Task { await coordinator.start() }
    }
    
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(coordinator: coordinator)
    }
    
    func makeCaptureViewModel() -> CaptureViewModel {
        CaptureViewModel(coordinator: coordinator)
    }
    
    func makePermissionViewModel() -> PermissionViewModel {
        PermissionViewModel(coordinator: coordinator)
    }
    
    func makeSettingViewModel() -> SettingViewModel {
        SettingViewModel(coordinator: coordinator)
    }
}
