//
//  MemoryUsage.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import Darwin

struct MemoryUsage: Hashable, Sendable {
    let used: Double
    let total: Double
    var free: Double { total - used }
    var usagePercentage: Double {
        guard total > 0 else { return 0 }

        let ratio = used / total
        
        return fmax(0.0, fmin(1.0, ratio))
    }
}
