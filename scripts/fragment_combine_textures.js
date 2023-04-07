
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
                                    texture2d<float> textureTwo [[ texture(2) ]],
                                    texture2d<float> textureThree [[ texture(3) ]],
                                    texture2d<float> textureFour [[ texture(4) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);

    float4 one = textureOne.sample(textureSampler, in.texCoord);
    float4 two = textureTwo.sample(textureSampler, in.texCoord);
    float4 three = textureThree.sample(textureSampler, in.texCoord);
    float4 four = textureFour.sample(textureSampler, in.texCoord);

    float2 uv = in.texCoord;

    float4 color;

    if (point.x < 0.25) {
        color = max(max(max(one, two), three), four);
    } else if (point.x < 0.5) {
        color = mix(mix(mix(one, two, point.y), three, point.y), four, point.y);
    } else if (point.x < 0.75) {
        color = one + two + three + four;
        color = point.y * color;
    } else {
        color = one * two * three * four;
        color = 20 * point.y * color;
    }

    return color;
}
`;

let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir).filter(v=>texel.isMovie(v)).filter(v=>texel.isPlayable(v));

layer = texel.Layer();
layer.size = texel.size.map(v=>v*0.9)
layer.position = texel.size.map(v=>v/2);
fragment = texel.Fragment();
fragment.source = src;
fragment.textureOne     = texel.Movie(files[Math.floor(Math.random()*files.length)], true, true);
fragment.textureTwo     = texel.Movie(files[Math.floor(Math.random()*files.length)], true, true);
fragment.textureThree   = texel.Movie(files[Math.floor(Math.random()*files.length)], true, true);
fragment.textureFour    = texel.Movie(files[Math.floor(Math.random()*files.length)], true, true);
fragment.textureOne.start();
fragment.textureTwo.start();
fragment.textureThree.start();
fragment.textureFour.start();
layer.content = fragment;
layer.contentScaling = 'stretch';
texel.layers = [layer];

global.gc();

