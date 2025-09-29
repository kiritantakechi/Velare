//
//  DashboardViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class DashboardViewModel {
    private let coordinator: AppCoordinator
    private let monitorService: SystemMonitorService

    var cpuUsage: Double {
        monitorService.currentCPUUsage
    }

    var cpuUsagePercentage: String {
        String(format: "%.1f%%", monitorService.currentCPUUsage * 100)
    }

    var memoryUsage: MemoryUsage {
        monitorService.currentMemoryUsage
    }

    var memoryUsageDescription: String {
        String(format: "%.2f GB / %.2f GB", memoryUsage.used, memoryUsage.total)
    }

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.monitorService = coordinator.systemMonitorService
    }

    func startMonitoring() {
        monitorService.startMonitoring()
    }

    func stopMonitoring() {
        monitorService.stopMonitoring()
    }
}
