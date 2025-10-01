//
//  VideoFrame.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import Metal
import CoreMedia

struct VideoFrame {
    var texture: MTLTexture // 直接使用 Metal 纹理，效率最高
    let timestamp: CMTime
}
