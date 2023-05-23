//
//  Deferred.metal
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

#include <metal_stdlib>
using namespace metal;
#import "Vertex.h"
#import "Lighting.h"

struct GBufferOut {
  float4 albedo [[color(RenderTargetAlbedo)]];
  float4 normal [[color(RenderTargetNormal)]];
  float4 position [[color(RenderTargetPosition)]];
};

fragment GBufferOut fragment_gBuffer (
  VertexOut in [[stage_in]]
//  depth2d<float> shadowTexture [[texture(ShadowTexture)]]
//  constant Material &material [[buffer(MaterialBuffer)]]
) {
  GBufferOut out;
  out.albedo = float4(0.5, 0.4, 0.3, 1);
  out.normal = float4(normalize(in.worldNormal), 1.0);
  out.position = float4(in.worldPosition, 1.0);
  return out;
}

constant float3 vertices[6] = {
  float3(-1,  1,  0),    // triangle 1
  float3( 1, -1,  0),
  float3(-1, -1,  0),
  float3(-1,  1,  0),    // triangle 2
  float3( 1,  1,  0),
  float3( 1, -1,  0)
};

vertex VertexOut vertex_quad(uint vertexID [[vertex_id]])
{
  VertexOut out {
    .position = float4(vertices[vertexID], 1)
  };
  return out;
}

fragment float4 fragment_deferredSun(
  VertexOut in [[stage_in]],
  constant Parameters &parameters [[buffer(ParametersBuffer)]],
  constant Light *lights [[buffer(LightBuffer)]],
  texture2d<float> albedoTexture [[texture(BaseColourTexture)]],
  texture2d<float> normalTexture [[texture(NormalTexture)]],
  texture2d<float> positionTexture [[texture(PositionTexture)]])
{
  uint2 coord = uint2(in.position.xy);
  float4 albedo = albedoTexture.read(coord);
  float3 normal = normalTexture.read(coord).xyz;
  float3 position = positionTexture.read(coord).xyz;
  float3 colour = phongLighting(
    normal,
    position,
    parameters,
    lights,
    albedo.xyz
  );
  colour *= albedo.a;
  return float4(colour, 1);
//  return float4(1, 0, 0, 1);
}
