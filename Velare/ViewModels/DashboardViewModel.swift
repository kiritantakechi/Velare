//
//  DashboardViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class DashboardViewModel {
    private unowned let coordinator: AppCoordinator

    private unowned let monitorService: SystemMonitorService

    var cpuUsage: Double {
        monitorService.currentCPUUsage
    }

    var cpuUsagePercentage: String {
        unsafe String(format: "%.1f%%", monitorService.currentCPUUsage * 100)
    }

    var memoryUsage: MemoryUsage {
        monitorService.currentMemoryUsage
    }

    var memoryUsageDescription: String {
        unsafe String(format: "%.2f GB / %.2f GB", memoryUsage.used, memoryUsage.total)
    }

    init(coordinator: consuming AppCoordinator) {
        self.monitorService = coordinator.systemMonitorService

        self.coordinator = consume coordinator
    }

    func onAppear() {
        monitorService.startMonitoring()
    }

    func onDisappear() {
        monitorService.stopMonitoring()
    }
}
