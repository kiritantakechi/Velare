//
//  RingIndex.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import Synchronization

struct RingIndex: Sendable, ~Copyable {
    private let count: Int
    private let index = Atomic<Int>(0)
    
    init(count: Int) {
        self.count = count
    }
    
    // 获取下一个索引
    mutating func next() -> Int {
        var current: Int
        var nextIndex: Int
        repeat {
            current = index.load(ordering: .relaxed)
            nextIndex = (current + 1) % count
        } while !index.compareExchange(expected: current, desired: nextIndex, ordering: .acquiringAndReleasing).exchanged
        return current
    }
}
