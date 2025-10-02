//
//  MetalView.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import MetalKit
import SwiftUI

struct MetalView: NSViewRepresentable {
    @State var viewModel: MetalViewModel

    let texture: MTLTexture?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
            
        // ✅ 使用来自 CacheService 的 device
        mtkView.device = viewModel.device
            
        mtkView.framebufferOnly = false
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = true
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            
        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        if context.coordinator.texture !== texture {
            context.coordinator.texture = texture
            nsView.setNeedsDisplay(nsView.bounds)
        }
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView // 用于访问 cacheService
        var texture: MTLTexture?
            
        // ✅ Command Queue 也从 cacheService 的 device 创建
        private let commandQueue: MTLCommandQueue

        init(_ parent: MetalView) {
            self.parent = parent
            // ✅ 在初始化时创建一次 Command Queue
            guard let commandQueue = parent.viewModel.device.makeCommandQueue() else {
                fatalError("无法创建 Metal Command Queue")
            }
            self.commandQueue = commandQueue
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let texture = texture,
                  let drawable = view.currentDrawable,
                  // ✅ 使用 coordinator持有的 commandQueue
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else {
                return
            }
                
            blitEncoder.copy(from: texture, to: drawable.texture)
            blitEncoder.endEncoding()
                
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
