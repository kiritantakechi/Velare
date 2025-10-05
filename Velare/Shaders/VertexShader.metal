//
//  VertexShader.metal
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

#include "ShaderTypes.metal"

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              const device float4* vertices [[buffer(0)]])
{
    VertexOut out;
    out.position = float4(vertices[vertexID].xy, 0.0, 1.0);
    out.texCoord = vertices[vertexID].zw;
    return out;
}
