//
//  MetalPipeline.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import Metal
import SwiftUI

final class MetalPipeline {
    private(set) var device: any MTLDevice
    private(set) var pipeline: (any MTLRenderPipelineState)!

    init(device: any MTLDevice) {
        self.device = device
        buildPipeline()
    }

    private func buildPipeline() {
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "vertexShader")!
        let fragmentFunc = library.makeFunction(name: "fragmentShader")!

        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction = vertexFunc
        desc.fragmentFunction = fragmentFunc
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.pipeline = try! device.makeRenderPipelineState(descriptor: desc)
    }
}
