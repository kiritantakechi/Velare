//
//  MemoryUsage.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

struct MemoryUsage: Sendable {
    let used: Double
    let total: Double
    var free: Double { total - used }
    var usagePercentage: Double {
        // 1. 增加一个 guard 语句，防止 total 为 0 时发生除法错误
        guard total > 0 else { return 0 }

        // 2. 计算比例
        let ratio = used / total

        // 3. 增加一个 clamp 操作，确保结果永远不会因为微小的计算误差而超出 0...1 的范围
        return max(0.0, min(1.0, ratio))
    }
}
