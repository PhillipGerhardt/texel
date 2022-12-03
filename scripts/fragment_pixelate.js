
src = `
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} FragmentData;

float RoundToNearest(float n, float x) {
    return round(n / x) * x;
}

[[fragment]] float4 fragmentSource( FragmentData in [[stage_in]],
                                    constant float& time [[ buffer(3) ]],
                                    constant float2& point [[ buffer(4) ]],
                                    texture2d<float> textureOne [[ texture(1) ]]
                                    )
{
    constexpr sampler textureSampler(filter::nearest, mip_filter::nearest);

    float2 uv = in.texCoord;

    float factor = 10;

    uv.x = RoundToNearest(uv.x, point.x / factor);
    uv.y = RoundToNearest(uv.y, point.x / factor);

    float4 color = textureOne.sample(textureSampler, uv);

    // float d = length(uv - in.texCoord);
    // if (d > point.x / (factor * 2)) {
    //     color *= 0;
    // }

    return color;
}
`;

let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir, true).filter(v=>texel.isMovie(v)).filter(v=>texel.canReadAsset(v));
files = texel.shuffle(files);
let file = files[0];
console.log('file', file);
movie = texel.Movie(file, true, true);
movie.start();
preview = texel.Layer();
preview.content = movie;

layer = texel.Layer();
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
fragment.source = src;
fragment.textureOne = movie;
layer.content = fragment;
layer.contentScaling = 'stretch';

texel.layers = [preview, layer];

