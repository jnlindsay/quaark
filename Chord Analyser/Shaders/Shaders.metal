//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
#import "../Shared/Common.h"
using namespace metal;

struct VertexIn {
  float4 position [[attribute(Position)]];
//  float3 normal [[attribute(1)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 colour;
  float3 worldPosition;
  float3 worldNormal;
};

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
  constant float4 &colour [[buffer(ColourBuffer)]]
) {
  float4 position =
      uniforms.projectionMatrix
    * uniforms.viewMatrix
    * uniforms.modelMatrix
    * in.position;
  VertexOut out {
    .position = position,
    .colour = colour,
    .worldPosition = (uniforms.modelMatrix * in.position).xyz
//    .worldNormal = uniforms.normalMatrix * in.normal
  };
  return out;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]]
) {
  return in.colour;
}
