
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
                                    constant float& time [[ buffer(3) ]],
                                    constant float2& point [[ buffer(4) ]])
{
    float c = 0;
    if (point.x > in.texCoord.x && point.y > 1 - in.texCoord.y) {
        c = 1;
    }
    return float4(c);
}
`;

layer = texel.Layer();
texel.layers = [layer];
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
layer.content = fragment;
fragment.source = src;



