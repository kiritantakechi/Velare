//
//  FragmentShader.metal
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

#include "ShaderTypes.metal"

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> tex [[texture(0)]])
{
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    return tex.sample(s, in.texCoord);
}
