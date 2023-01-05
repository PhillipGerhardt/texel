
src = `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} FragmentData;

float sdRoundBox( float2 p, float2 b, float r )
{
    return length(max(abs(p)-b+r,0.0))-r;
}

[[fragment]] float4 fragmentSource( FragmentData in [[stage_in]],
                                    constant float& time [[ buffer(3) ]],
                                    constant float2& point [[ buffer(4) ]]
                                    )
{
    float2 uv = in.texCoord;
    uv *= 2;
    uv -= 0.5;
    float2 halfRes = 50;
    float iRadius = 50 * point.x;
    float2 fragCoord = uv * 100;
    float b = sdRoundBox( fragCoord - halfRes, halfRes, iRadius );
    float c = 1 - smoothstep(0.0, 1.0, b);
    // float c = b;
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



