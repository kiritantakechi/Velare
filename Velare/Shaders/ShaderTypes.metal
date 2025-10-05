//
//  ShaderTypes.metal
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]]; // NDC 坐标
    float2 texCoord;              // 纹理坐标
};
