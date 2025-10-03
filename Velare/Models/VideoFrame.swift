//
//  VideoFrame.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import CoreMedia
import Metal

struct VideoFrame: Sendable {
    var texture: any MTLTexture // 直接使用 Metal 纹理，效率最高
    let timestamp: CMTime

    init?(from sampleBuffer: CMSampleBuffer, textureCache: CVMetalTextureCache) {
        // 1. 从 sampleBuffer 中获取时间戳
        self.timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        // 2. 从 sampleBuffer 中获取图像数据 (CVPixelBuffer)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("错误：无法从 CMSampleBuffer 中获取 CVImageBuffer")
            return nil
        }

        // 3. 获取视频帧的宽高
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        // 4. 使用 textureCache 从 imageBuffer 创建一个 Metal 纹理 (零拷贝)
        var cvMetalTexture: CVMetalTexture?
        let status = unsafe CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            imageBuffer,
            nil,
            .bgra8Unorm, // 假设 SCStream 输出的是 BGRA 格式
            width,
            height,
            0,
            &cvMetalTexture
        )

        // 5. 检查创建是否成功，并从中提取出 MTLTexture
        if status == kCVReturnSuccess, let metalTexture = cvMetalTexture {
            // CVMetalTextureGetTexture 会返回一个可选的 MTLTexture，我们解包它
            guard let originalTexture = CVMetalTextureGetTexture(metalTexture) else {
                print("错误：无法从 CVMetalTexture 中获取 MTLTexture")
                return nil
            }
            // Create a new texture view to ensure a unique texture object for this frame.
            // This is crucial for Sendable conformance and preventing data races.
            guard let newTexture = originalTexture.makeTextureView(pixelFormat: originalTexture.pixelFormat) else {
                print("错误：无法从原始纹理创建新的 TextureView")
                return nil
            }
            self.texture = newTexture
        } else {
            print("错误：无法从 CVImageBuffer 创建 Metal 纹理，状态码: \(status)")
            return nil
        }
    }
}
