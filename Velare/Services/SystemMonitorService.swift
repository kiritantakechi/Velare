//
//  SystemMonitorService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

@Observable
final class SystemMonitorService {
    private(set) var currentCPUUsage: Double = 0.0
    private(set) var currentMemoryUsage: MemoryUsage = .init(used: 0, total: 0)

    private var monitoringTask: Task<Void, Never>?
    private var previousCpuLoadInfo: host_cpu_load_info?

    init() {
        Task { await updateMonitoring() }
    }

    func startMonitoring(interval: TimeInterval = 1.0) {
        guard monitoringTask == nil else { return }

        monitoringTask = Task {
            await monitor(interval: interval)
        }
    }

    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        previousCpuLoadInfo = nil // 重置
    }

    private func monitor(interval: TimeInterval = 1.0) async {
        await updateMonitoring()
        do {
            try await Task.sleep(for: .seconds(interval))
            await monitor(interval: interval)
        } catch { print("Monitoring stopped due to cancellation.") }
    }

    func updateMonitoring() async {
        await updateCPUUsage()
        await updateMemoryUsage()
    }

    private func updateMemoryUsage() async {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let kerr = unsafe withUnsafeMutablePointer(to: &stats) {
            unsafe $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                unsafe host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }

        guard kerr == KERN_SUCCESS else { return }

        let gbFactor = 1.0 / Double(1 << 30)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) * gbFactor

        let counts = UInt64(stats.wire_count) + UInt64(stats.active_count)
        let usedMemory = Double(counts * UInt64(vm_kernel_page_size)) * gbFactor

        currentMemoryUsage = MemoryUsage(used: usedMemory, total: totalMemory)
    }

    private func updateCPUUsage() async {
        var cpuLoadInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

        let result = unsafe withUnsafeMutablePointer(to: &cpuLoadInfo) {
            unsafe $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                unsafe host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard result == KERN_SUCCESS, let prevInfo = previousCpuLoadInfo else {
            previousCpuLoadInfo = cpuLoadInfo
            return
        }

        let userTicks = Double(cpuLoadInfo.cpu_ticks.0 - prevInfo.cpu_ticks.0)
        let systemTicks = Double(cpuLoadInfo.cpu_ticks.1 - prevInfo.cpu_ticks.1)
        let idleTicks = Double(cpuLoadInfo.cpu_ticks.2 - prevInfo.cpu_ticks.2)
        let niceTicks = Double(cpuLoadInfo.cpu_ticks.3 - prevInfo.cpu_ticks.3)

        let totalTicks = userTicks + systemTicks + idleTicks + niceTicks

        if totalTicks > 0 {
            let usage = (userTicks + systemTicks + niceTicks) / totalTicks
            currentCPUUsage = fmax(0.0, fmin(1.0, usage)) // 保证值在 0-1 之间
        }

        previousCpuLoadInfo = cpuLoadInfo
    }
}
