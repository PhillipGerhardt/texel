//
//  Shaders.metal
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} VertexIn;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} FragmentData;

// MARK: - content rgba

[[vertex]] FragmentData vertexContent(VertexIn in [[stage_in]],
                                      constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                                      constant Model & model [[ buffer(BufferIndexModel) ]]
                                      )
{
    FragmentData out;
    float4 size = float4(model.size, 1, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    return out;
}

[[fragment]] float4 fragmentContent(FragmentData in [[stage_in]],
                                    constant Model & model [[ buffer(BufferIndexModel) ]],
                                    texture2d<float> texture [[ texture(TextureIndexOne) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);
    float4 rgba = texture.sample(textureSampler, in.texCoord);
//    rgba.a = 1; // for RFB
    return rgba * model.color;
}

// MARK: - layer

[[vertex]] FragmentData vertexLayer(VertexIn in [[stage_in]],
                                    constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                                    constant Model & model [[ buffer(BufferIndexModel) ]]
                                    )
{
    FragmentData out;
    float4 size = float4(model.size, 0, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    return out;
}

[[fragment]] float4 fragmentLayer(FragmentData in [[stage_in]],
                                  constant Model & model [[ buffer(BufferIndexModel) ]]
                                  )
{
    return model.color;
}

// MARK: - stencil

[[vertex]] FragmentData vertexStencil(VertexIn in [[stage_in]],
                                      constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                                      constant Model & model [[ buffer(BufferIndexModel) ]]
                                      )
{
    FragmentData out;
    float4 size = float4(model.size, 1, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    return out;
}

[[fragment]] void fragmentStencil(FragmentData in [[stage_in]],
                                  constant Model & model [[ buffer(BufferIndexModel) ]]
                                  )
{
}
