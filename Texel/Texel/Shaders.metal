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
                                      constant Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
                                      constant Model& model [[ buffer(BufferIndexModel) ]]
                                      )
{
    FragmentData out;
    float4 size = float4(model.size, 1, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    return out;
}

[[vertex]] FragmentData vertexContentFlipped(VertexIn in [[stage_in]],
                                      constant Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
                                      constant Model& model [[ buffer(BufferIndexModel) ]]
                                      )
{
    FragmentData out;
    float4 size = float4(model.size, 1, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    out.texCoord.y = 1 - out.texCoord.y;
    return out;
}

[[fragment]] float4 fragmentContent(FragmentData in [[stage_in]],
                                    constant Model& model [[ buffer(BufferIndexModel) ]],
                                    texture2d<float> texture [[ texture(TextureIndexOne) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);
//    constexpr sampler textureSampler(filter::nearest, mip_filter::linear);
    float4 rgba = texture.sample(textureSampler, in.texCoord);
    return rgba * model.color;
}

// MARK: - layer

[[vertex]] FragmentData vertexLayer(VertexIn in [[stage_in]],
                                    constant Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
                                    constant Model& model [[ buffer(BufferIndexModel) ]]
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
                                  constant Model& model [[ buffer(BufferIndexModel) ]]
                                  )
{
    return model.color;
}

// MARK: - ticker

[[vertex]] FragmentData vertexTicker(VertexIn in [[stage_in]],
                                            constant Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
                                            constant Model& model [[ buffer(BufferIndexModel) ]]
                                            )
{
    FragmentData out;
    float4 size = float4(model.size, 1, 1);
    float4 position = float4(in.position, 1.0) * size;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * model.matrix * position;
    out.texCoord = in.texCoord;
    return out;
}

[[fragment]] float4 fragmentTicker(FragmentData in [[stage_in]],
                                          constant Model& model [[ buffer(BufferIndexModel) ]],
                                          constant ModelTicker& modelTicker [[ buffer(BufferIndexModelTicker) ]],
                                          texture2d<float> textureA [[ texture(TextureIndexOne) ]],
                                          texture2d<float> textureB [[ texture(TextureIndexTwo) ]]
                                          )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);
    float2 uv = in.texCoord;
    uv.x += modelTicker.offset;

    float4 rgba;

    if (uv.x < 1) {
        rgba = textureA.sample(textureSampler, uv);
    } else {
        rgba = textureB.sample(textureSampler, uv - float2(1,0));
    }
    rgba *= model.color;

    return rgba;
}

// MARK: - stencil

[[vertex]] FragmentData vertexStencil(VertexIn in [[stage_in]],
                                      constant Uniforms& uniforms [[ buffer(BufferIndexUniforms) ]],
                                      constant Model& model [[ buffer(BufferIndexModel) ]]
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

// MARK: - wave generation

kernel void waveGeneration(texture2d<float, access::read> one [[texture(TextureIndexOne)]],
                           texture2d<float, access::read> two [[texture(TextureIndexTwo)]],
                           texture2d<float, access::write> three [[texture(TextureIndexThree)]],
                           uint2 index [[thread_position_in_grid]])
{
    uint2 l = index + uint2(-1, 0);
    uint2 r = index + uint2(+1, 0);
    uint2 t = index + uint2( 0,+1);
    uint2 b = index + uint2( 0,-1);

    float4 w = one.read(l);
    float4 e = one.read(r);
    float4 n = one.read(t);
    float4 s = one.read(b);

    float4 color = (n+e+s+w)/2.0;
    float4 center = two.read(index);
    color = color - center;
    color = color * 0.99; // - color * 0.01;
    three.write(color, index);
}

[[fragment]] float4 fragmentWave(FragmentData in [[stage_in]],
                                    constant Model& model [[ buffer(BufferIndexModel) ]],
                                    texture2d<float> texture [[ texture(TextureIndexOne) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);
    float4 rgba = texture.sample(textureSampler, in.texCoord);
    rgba = abs(rgba);
    return rgba * model.color;
}

// MARK: - game of life

kernel void gameOfLifeGeneration(texture2d<float, access::read> one [[texture(TextureIndexOne)]],
                                 texture2d<float, access::write> two [[texture(TextureIndexTwo)]],
                                 uint2 index [[thread_position_in_grid]])
{

    uint2 c00 = index - uint2(-1, -1);
    uint2 c10 = index - uint2( 0, -1);
    uint2 c20 = index - uint2( 1, -1);
    uint2 c01 = index - uint2(-1,  0);
    uint2 c11 = index - uint2( 0,  0);
    uint2 c21 = index - uint2( 1,  0);
    uint2 c02 = index - uint2(-1,  1);
    uint2 c12 = index - uint2( 0,  1);
    uint2 c22 = index - uint2( 1,  1);

    float4 v00 = one.read(c00);
    float4 v10 = one.read(c10);
    float4 v20 = one.read(c20);
    float4 v01 = one.read(c01);
    float4 v11 = one.read(c11);
    float4 v21 = one.read(c21);
    float4 v02 = one.read(c02);
    float4 v12 = one.read(c12);
    float4 v22 = one.read(c22);

    int n = 0;
    if (v00.x > 0.5) { n += 1; }
    if (v10.x > 0.5) { n += 1; }
    if (v20.x > 0.5) { n += 1; }
    if (v01.x > 0.5) { n += 1; }
//    if (c11.x > 0.5) { s += 1; }
    if (v21.x > 0.5) { n += 1; }
    if (v02.x > 0.5) { n += 1; }
    if (v12.x > 0.5) { n += 1; }
    if (v22.x > 0.5) { n += 1; }

    float c = 0;

    if (v11.x > 0.5) {
        if (n == 2 || n == 3) {
            c = 1;
        }
    } else {
        if (n == 3) {
            c = 1;
        }
    }

    two.write(c, index);
}
