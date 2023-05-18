//
//  Shared.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 15/5/2023.
//

#ifndef Shared_h
#define Shared_h

#import <simd/simd.h>

/*
 To understand the following matrices, study
 the mathematics of 3D graphics transformations.
 
 This struct is called `Uniforms` because these
 values are always constant throughout an entire
 shader process.
 */
typedef struct {
  simd_float4x4 modelMatrix;      // object space -> world space
  simd_float4x4 viewMatrix;       //  world space -> camera space
  simd_float4x4 projectionMatrix; // camera space -> clip space
  simd_float3x3 normalMatrix;
} Uniforms;

typedef struct {
  uint lightCount;
  simd_float3 cameraPosition;
} Parameters;

typedef enum {
  Position = 0,
  Normal = 1,
  UV = 2,
  Colour = 3
} MetalAttributes;

typedef enum {
  VertexBuffer = 0,
  UVBuffer = 1,
  ColourBuffer = 2,
  UniformsBuffer = 11,
  ParametersBuffer = 12,
  LightBuffer = 13
} BufferIndices;

// LIGHTING

typedef enum {
  UnusedLight = 0,
  SunLight = 1,
  SpotLight = 2,
  PointLight = 3,
  AmbientLight = 4
} LightType;

typedef struct {
  LightType type;
  simd_float3 position;
  simd_float3 colour;
  simd_float3 specularColour;
  float radius;
  simd_float3 attenutation;
  float coneAngle;
  simd_float3 coneDirection;
  simd_float3 coneAttenuation;
} Light;

#endif /* Shared_h */
