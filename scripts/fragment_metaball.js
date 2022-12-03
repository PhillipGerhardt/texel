
src = `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} FragmentData;

[[fragment]] float4 fragmentSource( FragmentData in [[stage_in]],
                                    constant float& time [[ buffer(3) ]])
{
    float2 uv = in.texCoord - 0.5;
    float2 p1 = float2(sin(time * 0.3), cos(time * .7)) * 0.5;
    float2 p2 = float2(sin(time * 0.5), cos(time * .5)) * 0.5;
    float2 p3 = float2(sin(time * 0.7), cos(time * .3)) * 0.5;
    float c = 0;
    c += 0.1 / distance(uv, p1);
    c += 0.1 / distance(uv, p2);
    c += 0.1 / distance(uv, p3);
    // c = smoothstep(0.7, 1.0, c);
    float4 color(c, c, c, 1.0);
    return color;
}
`;

layer = texel.Layer();
texel.layers = [layer];
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
layer.content = fragment;
fragment.source = src;



