
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
                                    texture2d<float> textureOne [[ texture(1) ]],
                                    texture2d<float> textureTwo [[ texture(2) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);

    float2 uv = in.texCoord;

    float4 two = textureTwo.sample(textureSampler, uv);

    uv.x += two.x / 100;
    uv.y += two.y / 100;

    float4 one = textureOne.sample(textureSampler, uv);

    float4 color;
    color = one;
    return color;
}
`;

let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir).filter(v=>texel.isMovie(v)).filter(v=>texel.canReadAsset(v));

layer = texel.Layer();
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
fragment.source = src;
wave = texel.Wave([256, 256]);
fragment.textureOne     = texel.Movie(files[Math.floor(Math.random()*files.length)], true, true);
fragment.textureTwo     = wave;
fragment.textureOne.start();
layer.content = fragment;
layer.contentScaling = 'stretch';

lw = texel.Layer();
lw.size = texel.size.map(v=>v*0.9)
lw.position = texel.size.map(v=>v/2);
lw.content = wave;
lw.contentScaling = 'stretch';
lw.draw = false;
lw.contentColor = 0;

texel.layers = [layer, lw];

global.gc();

