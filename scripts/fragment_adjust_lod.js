
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
                                    constant float2& point [[ buffer(4) ]],
                                    texture2d<float> textureOne [[ texture(1) ]]
                                    )
{
    constexpr sampler textureSampler(filter::nearest, mip_filter::nearest);
    float lod = (textureOne.get_num_mip_levels() * point.x);
    float4 one = textureOne.sample(textureSampler, in.texCoord, level(lod));
    return one;
}
`;

let dir = path.join(os.homedir(), 'Pictures');
let files = texel.contentsOfDirectory(dir, true).filter(v=>texel.isImage(v));

layer = texel.Layer();
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
fragment.source = src;
fragment.textureOne     = texel.Image(files[Math.floor(Math.random()*files.length)]);
fragment.textureOne.start();
layer.content = fragment;
layer.contentScaling = 'stretch';
texel.layers = [layer];

global.gc();

