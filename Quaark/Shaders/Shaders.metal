//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"
#import "Vertex.h"

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  uint instanceId [[instance_id]],
  constant float4 &colour [[buffer(ColourBuffer)]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
  constant InstancesData* instancesData [[buffer(InstancesBuffer)]]
) {
  float4 position =
      uniforms.projectionMatrix
    * uniforms.viewMatrix
    * instancesData[instanceId].modelMatrix
    * in.position;
  float3 normal = in.normal;
  VertexOut out {
    .position = position,
    .normal = normal,
    .colour = colour,
    .worldPosition = (instancesData[instanceId].modelMatrix * in.position).xyz,
    .worldNormal = instancesData[instanceId].normalMatrix * in.normal
  };
  return out;
}
