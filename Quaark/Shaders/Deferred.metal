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
  float4 bloom [[color(RenderTargetBloom)]];
};

fragment GBufferOut fragment_gBuffer (
  VertexOut in [[stage_in]]
) {
  GBufferOut out;
  out.albedo = float4(0.5, 0, 0.5, 1);
  out.normal = float4(normalize(in.worldNormal), 1.0);
  out.position = float4(in.worldPosition, 1.0);
  out.bloom = float4(0, 1, 0, 1);
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

vertex VertexOut vertex_quad(uint vertexId [[vertex_id]])
{
  VertexOut out {
    .position = float4(vertices[vertexId], 1)
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
}

struct PointLightIn {
  float4 position [[attribute(Position)]];
};

struct PointLightOut {
  float4 position [[position]];
  uint instanceId [[flat]];
};

vertex PointLightOut vertex_pointLight(
  uint instanceId [[instance_id]],
  uint vertexId [[vertex_id]]
) {
  float4 position = float4(vertices[vertexId], 1);
  PointLightOut out {
    .position = position,
    .instanceId = instanceId
  };
  return out;
}

fragment float4 fragment_pointLight(
  PointLightOut in [[stage_in]],
  texture2d<float> normalTexture [[texture(NormalTexture)]],
  texture2d<float> positionTexture [[texture(PositionTexture)]],
  texture2d<float> bloomTexture [[texture(BloomTexture)]],
  constant Light *lights [[buffer(LightBuffer)]]
) {
  Light light = lights[in.instanceId];
  uint2 coords = uint2(in.position.xy);
  float3 normal = normalTexture.read(coords).xyz;
  float3 position = positionTexture.read(coords).xyz;
  
  // ! TODO: THIS COLOUR SHOULD NOT BE SET HERE!!!
  vector_float3 baseColour = float3(1, 1, 1);
  
  float3 lighting =
    calculatePointLight(light, position, normal, baseColour);
  return float4(lighting, 1);
}
