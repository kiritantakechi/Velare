//
//  CacheService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class CacheService {
    private(set) var device: (any MTLDevice)!
    private(set) var textureCache: CVMetalTextureCache!

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("你的设备不支持 Metal。")
        }
        self.device = device

        var cache: CVMetalTextureCache?
        let result = unsafe CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        guard result == kCVReturnSuccess, let textureCache = cache else {
            fatalError("无法创建 CVMetalTextureCache。")
        }
        self.textureCache = textureCache
    }
}
