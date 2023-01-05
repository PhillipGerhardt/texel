
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
                                    texture2d<float> textureOne [[ texture(1) ]]
                                    )
{
    constexpr sampler textureSampler(filter::linear, mip_filter::linear);

    float s00 = length(textureOne.sample(textureSampler, in.texCoord, int2(-1, -1)).rgb);
    float s10 = length(textureOne.sample(textureSampler, in.texCoord, int2( 0, -1)).rgb);
    float s20 = length(textureOne.sample(textureSampler, in.texCoord, int2( 1, -1)).rgb);

    float s01 = length(textureOne.sample(textureSampler, in.texCoord, int2(-1,  0)).rgb);
    float s11 = length(textureOne.sample(textureSampler, in.texCoord, int2( 0,  0)).rgb);
    float s21 = length(textureOne.sample(textureSampler, in.texCoord, int2( 1,  0)).rgb);

    float s02 = length(textureOne.sample(textureSampler, in.texCoord, int2(-1,  1)).rgb);
    float s12 = length(textureOne.sample(textureSampler, in.texCoord, int2( 0,  1)).rgb);
    float s22 = length(textureOne.sample(textureSampler, in.texCoord, int2( 1,  1)).rgb);

    float sx = s00 + 2 * s10 + s20 - (s02 + 2 * s12 + s22); 
    float sy = s00 + 2 * s01 + s02 - (s20 + 2 * s21 + s22); 
 
    float g = sx * sx + sy * sy; 
 
    if (g > 1) { 
        return float4(1.0); 
    }
    else {
        return float4(0.0,0.0,0.0,1.0); 
    }
}
`;

let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir).filter(v=>texel.isMovie(v));
files = texel.shuffle(files);
console.log('file', files[0]);
let movie = files[0];
movie = texel.Movie(movie, true, true);
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

texel.layers = [preview, layer];

