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
        private let quadVertexBuffer: any MTLBuffer

        private var renderQueue = InlineMPSCQueue<24, any MTLTexture>()

        init(_ parent: MetalView, gpuPool: GPUPool) {
            self.context = gpuPool.acquireContext()
            self.commandQueue = context.commandQueue
            self.pipeline = MetalPipeline(device: context.device)

            let quadVertices: [Float] = [
                -1, -1, 0, 1,
                1, -1, 1, 1,
                -1, 1, 0, 0,
                1, 1, 1, 0
            ]
            self.quadVertexBuffer = unsafe context.device.makeBuffer(
                bytes: quadVertices,
                length: MemoryLayout<Float>.size * quadVertices.count,
                options: [.storageModeShared]
            )!
        }

        func enqueueTexture(_ texture: (any MTLTexture)?) {
            guard let texture else { return }

            renderQueue.enqueue(texture)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            // 弹出最新纹理
            guard let textureToDraw = renderQueue.dequeue() else { return }

            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor
            else { return }

            let commandBuffer = commandQueue.makeCommandBuffer()!

            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

            // 设置 pipeline
            encoder.setRenderPipelineState(pipeline.pipeline)
            // 设置纹理
            encoder.setFragmentTexture(textureToDraw, index: 0)
            // 设置顶点
            encoder.setVertexBuffer(quadVertexBuffer, offset: 0, index: 0)

            encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
