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
} Uniforms;

typedef struct {
  uint lightCount;
  simd_float3 cameraPosition;
} Parameters;

typedef struct {
  simd_float4x4 modelMatrix;
  simd_float3x3 normalMatrix;
  simd_float4 albedo;
} InstancesData;

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
  InstancesBuffer = 13,
  LightBuffer = 14
//  MaterialBuffer = 14
} BufferIndices;

typedef enum {
  BaseColourTexture = 0,
  NormalTexture = 1,
  PositionTexture = 2,
  BloomTexture = 3
//  RoughnessTexture = 3,
//  MetallicnessTexture = 4,
//  AmbientOcclusionTexture = 5,
//  ShadowTexture = 6
} TextureIndices;

typedef enum {
  RenderTargetDefault = 0,
  RenderTargetAlbedo = 1,
  RenderTargetNormal = 2,
  RenderTargetPosition = 3,
  RenderTargetBloom = 4
} RenderTargetIndices;

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
  vector_float3 position;
  vector_float3 colour;
  vector_float3 specularColour;
  float radius;
  vector_float3 attenuation;
  float coneAngle;
  vector_float3 coneDirection;
  vector_float3 coneAttenuation;
    // suppose coneAttenuation = [x, y, z]
    // The attenuation formula is:
    // 1 / (x + y * distance + z * distance^2)
} Light;

// TODO: make this struct more general?
typedef struct {
  vector_float3 position;
} Sphere;

#endif /* Shared_h */
