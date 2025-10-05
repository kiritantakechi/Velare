//
//  GPUPool.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import Foundation
import Metal
import SwiftUI

final class GPUPool {
    private(set) var device: any MTLDevice

    private var contexts: [MetalContext] = []
    private var contextIndex: RingIndex

    init(contextCount: Int = 4) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("设备不支持 Metal")
        }

        self.device = consume device
        self.contextIndex = RingIndex(count: contextCount)
        self.contexts = (0 ..< contextCount).map { _ in MetalContext(device: self.device) }
    }

    func acquireContext() -> MetalContext {
        let idx = contextIndex.next()

        return contexts[idx]
    }

    func flushAllCaches() {
        contexts.forEach { $0.flushCache() }
    }
}
