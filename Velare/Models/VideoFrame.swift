//
//  VideoFrame.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import CoreMedia
import Metal

struct VideoFrame: Hashable, Sendable {
    private var textureIdentifier: String

    var texture: any MTLTexture
    let timestamp: CMTime

    init(texture: consuming any MTLTexture, timestamp: consuming CMTime) {
        self.textureIdentifier = "\(texture.label ?? "NoLabel")_\(texture.width)_\(texture.height)"

        self.texture = consume texture
        self.timestamp = consume timestamp
    }

    init?(from sampleBuffer: borrowing CMSampleBuffer, using context: borrowing MetalContext) {
        self.timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("错误：无法获取 CVPixelBuffer")
            return nil
        }

        guard let texture = context.makeTexture(from: pixelBuffer, pixelFormat: .bgra8Unorm) else {
            print("错误：无法生成 Metal 纹理")
            return nil
        }
        
        self.textureIdentifier = "\(texture.label ?? "NoLabel")_\(texture.width)_\(texture.height)"

        self.texture = consume texture
    }

    static func createAsync(from sampleBuffer: borrowing CMSampleBuffer,
                            using context: borrowing MetalContext,
                            completion: @escaping (consuming VideoFrame?) -> Void)
    {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            completion(nil)
            return
        }

        context.makeTextureAsync(from: pixelBuffer, pixelFormat: .bgra8Unorm) { texture in
            guard let texture else {
                completion(nil)
                return
            }

            let frame = VideoFrame(texture: texture, timestamp: timestamp)

            completion(consume frame)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(textureIdentifier) // 使用标识符而不是直接用 texture
        hasher.combine(timestamp)
    }

    // 实现 Equatable 协议
    static func == (lhs: borrowing VideoFrame, rhs: borrowing VideoFrame) -> Bool {
        return lhs.textureIdentifier == rhs.textureIdentifier && lhs.timestamp == rhs.timestamp
    }
}
