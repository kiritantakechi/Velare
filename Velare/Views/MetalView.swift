//
//  MetalView.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import MetalKit
import SwiftUI

struct MetalView: NSViewRepresentable {
    let gpuPool: GPUPool
    let texture: (any MTLTexture)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self, gpuPool: gpuPool)
    }

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = gpuPool.device

        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.framebufferOnly = true

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
        private let pipeline: MetalPipeline

        private var renderQueue: [(any MTLTexture)?] = Array(repeating: nil, count: 16)
        private var head = 0
        private var tail = 0
        private let queueLock = NSLock()

        init(_ parent: MetalView, gpuPool: GPUPool) {
            self.context = gpuPool.acquireContext()
            self.commandQueue = context.commandQueue
            self.pipeline = MetalPipeline(device: gpuPool.device)
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
            // 弹出最新纹理
            queueLock.lock()
            guard head != tail, let textureToDraw = renderQueue[head] else {
                queueLock.unlock()
                return
            }
            renderQueue[head] = nil
            head = (head + 1) % renderQueue.count
            queueLock.unlock()

            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor
            else { return }

            let commandBuffer = commandQueue.makeCommandBuffer()!

            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
            // 设置 pipeline
            encoder.setRenderPipelineState(pipeline.pipeline)
            // 设置纹理
            encoder.setFragmentTexture(textureToDraw, index: 0)

            // 顶点 buffer，四个顶点全屏 quad
            let quadVertices: [Float] = [
                -1, -1, 0, 1,
                1, -1, 1, 1,
                -1, 1, 0, 0,
                1, 1, 1, 0
            ]

            unsafe encoder.setVertexBytes(quadVertices, length: MemoryLayout<Float>.size * quadVertices.count, index: 0)

            encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
