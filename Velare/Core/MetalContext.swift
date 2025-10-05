//
//  MetalContext.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import CoreVideo
import Metal
import SwiftUI

final class MetalContext {
    let commandQueue: any MTLCommandQueue
    let textureCache: CVMetalTextureCache

    private var texturePool: [CVMetalTexture?] = [nil, nil, nil]
    private var poolIndex = 0

    init(device: any MTLDevice) {
        guard let queue = device.makeCommandQueue() else {
            fatalError("无法创建 CommandQueue")
        }
        self.commandQueue = queue

        var cache: CVMetalTextureCache?
        let result = unsafe CVMetalTextureCacheCreate(
            kCFAllocatorDefault,
            nil,
            device,
            nil,
            &cache
        )
        guard result == kCVReturnSuccess, let cache else {
            fatalError("无法创建 CVMetalTextureCache")
        }

        self.textureCache = consume cache
    }

    func makeTexture(from pixelBuffer: CVPixelBuffer,
                     pixelFormat: MTLPixelFormat,
                     planeIndex: Int = 0) -> (any MTLTexture)?
    {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

        var textureRef: CVMetalTexture?
        let status = unsafe CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            self.textureCache,
            pixelBuffer,
            nil,
            pixelFormat,
            width,
            height,
            planeIndex,
            &textureRef
        )

        guard status == kCVReturnSuccess,
              let cvTexture = textureRef,
              let texture = CVMetalTextureGetTexture(cvTexture)
        else { return nil }

        // triple buffer 复用
        self.poolIndex = (self.poolIndex + 1) % self.texturePool.count
        self.texturePool[self.poolIndex] = cvTexture

        return texture
    }

    func makeTextureAsync(from pixelBuffer: CVPixelBuffer,
                          pixelFormat: MTLPixelFormat,
                          planeIndex: Int = 0,
                          completion: @escaping ((any MTLTexture)?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let texture = self.makeTexture(from: pixelBuffer, pixelFormat: pixelFormat, planeIndex: planeIndex)
            completion(texture)
        }
    }

    func flushCache() {
        CVMetalTextureCacheFlush(self.textureCache, 0)
    }
}
