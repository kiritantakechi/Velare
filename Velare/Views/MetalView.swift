//
//  MetalView.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import MetalKit
import SwiftUI

struct MetalView: NSViewRepresentable {
    let gpuContextPool: GPUContextPool
    let texture: (any MTLTexture)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self, gpuContextPool: gpuContextPool)
    }

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = gpuContextPool.device

        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.framebufferOnly = false
        
        // 自动绘制
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 144
        
        // 手动绘制
//         mtkView.isPaused = true
//         mtkView.enableSetNeedsDisplay = true

        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.enqueueTexture(texture)
        
        // 手动绘制
//         nsView.setNeedsDisplay(nsView.bounds)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        let context: MetalContext
        private let commandQueue: any MTLCommandQueue

        private var renderQueue: [(any MTLTexture)?] = Array(repeating: nil, count: 16)
        private var head = 0
        private var tail = 0
        private let queueLock = NSLock()

        init(_ parent: MetalView, gpuContextPool: GPUContextPool) {
            self.context = gpuContextPool.acquireContext()
            self.commandQueue = context.commandQueue
        }

        func enqueueTexture(_ texture: (any MTLTexture)?) {
            guard let texture else { return }
            
            queueLock.lock()
            renderQueue[tail] = texture
            tail = (tail + 1) % renderQueue.count
            if tail == head { head = (head + 1) % renderQueue.count } // 队满覆盖最旧帧
            queueLock.unlock()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            queueLock.lock()
            guard head != tail, let textureToDraw = renderQueue[head] else {
                queueLock.unlock()
                return
            }
            renderQueue[head] = nil
            head = (head + 1) % renderQueue.count
            queueLock.unlock()

            guard let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else { return }

            blitEncoder.copy(from: textureToDraw, to: drawable.texture)
            blitEncoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
