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
    
    init() {}

    func startMonitoring(interval: TimeInterval = 1.0) {
        // 防止重复启动
        guard monitoringTask == nil else { return }

        monitoringTask = Task {
            while !Task.isCancelled {
                updateMonitoring()

                do {
                    // 等待指定的时间间隔
                    try await Task.sleep(for: .seconds(interval))
                } catch {
                    // 如果任务在睡眠时被取消，就退出循环
                    break
                }
            }
        }
    }

    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        previousCpuLoadInfo = nil // 重置
    }

    func updateMonitoring() {
        updateCPUUsage()
        updateMemoryUsage()
    }

    private func updateMemoryUsage() {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let kerr = unsafe withUnsafeMutablePointer(to: &stats) {
            unsafe $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                unsafe host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }

        guard kerr == KERN_SUCCESS else { return }

        let pageSize = Double(vm_kernel_page_size)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024 * 1024) // GB

        let wiredMemory = Double(stats.wire_count) * pageSize
        let activeMemory = Double(stats.active_count) * pageSize
        // let inactiveMemory = Double(stats.inactive_count) * pageSize
        // let compressedMemory = Double(stats.compressor_page_count) * pageSize

        // let usedMemory = (wiredMemory + activeMemory + inactiveMemory + compressedMemory) / (1024 * 1024 * 1024) // GB

        let usedMemory = (wiredMemory + activeMemory) / (1024 * 1024 * 1024) // GB

        currentMemoryUsage = MemoryUsage(used: usedMemory, total: totalMemory)
    }

    private func updateCPUUsage() {
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
            currentCPUUsage = max(0.0, min(1.0, usage)) // 保证值在 0-1 之间
        }

        previousCpuLoadInfo = cpuLoadInfo
    }
}
