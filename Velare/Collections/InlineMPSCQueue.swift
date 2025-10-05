//
//  InlineMPSCQueue.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import Synchronization

// 无锁 MPSC 队列，固定容量循环缓冲
struct InlineMPSCQueue<let count: Int, Element>: ~Copyable {
    private var buffer: InlineArray<count, Element?>
    
    private let head = Atomic<Int>(0) // 消费者索引
    private let tail = Atomic<Int>(0) // 生产者索引
    
    init() {
        buffer = InlineArray(repeating: nil)
    }
    
    // 多生产者安全入队
    mutating func enqueue(_ value: consuming Element) {
        while true {
            let currentTail = tail.load(ordering: .relaxed)
            let nextTail = (currentTail + 1) % count
            let currentHead = head.load(ordering: .acquiring)
            
            if nextTail == currentHead {
                // 队满，覆盖最旧元素
                head.store((currentHead + 1) % count, ordering: .releasing)
            }
            
            // 尝试原子更新 tail
            if tail.compareExchange(expected: currentTail, desired: nextTail, ordering: .acquiringAndReleasing).exchanged {
                buffer[currentTail] = consume value
                break
            }
            // 如果失败，重试
        }
    }
    
    // 单消费者安全出队
    mutating func dequeue() -> Element? {
        let currentHead = head.load(ordering: .relaxed)
        let currentTail = tail.load(ordering: .acquiring)
        
        guard currentHead != currentTail else { return nil }
        
        let value = buffer[currentHead]
        buffer[currentHead] = nil
        head.store((currentHead + 1) % count, ordering: .releasing)
        return value
    }
}
