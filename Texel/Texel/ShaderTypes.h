//
//  ShaderTypes.h
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//

#pragma once

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumBackingType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumBackingType;
#endif

#include <simd/simd.h>

typedef NS_ENUM(EnumBackingType, BufferIndex)
{
    BufferIndexUniforms         = 0,
    BufferIndexVertices         = 1,
    BufferIndexModel            = 2,
    BufferIndexTime             = 3,
    BufferIndexPoint            = 4,
};

typedef NS_ENUM(EnumBackingType, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
};

typedef NS_ENUM(EnumBackingType, TextureIndex)
{
    TextureIndexOne    = 1,
    TextureIndexTwo    = 2,
    TextureIndexThree  = 3,
    TextureIndexFour   = 4,
};

typedef struct
{
    simd_float4x4 projectionMatrix;
    simd_float4x4 viewMatrix;
} Uniforms;

typedef struct
{
    simd_float3 position;
    simd_float2 uv;
} Vertex;

typedef struct {
    simd_float4x4 matrix;
    simd_float4 color;
    simd_float2 size;
} Model;
