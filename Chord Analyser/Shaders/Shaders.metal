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
  float4 position [[attribute(0)]];
};

struct VertexOut {
  float4 position [[position]];
  bool keyPressed;
};

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(11)]],
  constant bool &keyPressed [[buffer(12)]]
) {
  float4 position =
      uniforms.projectionMatrix
    * uniforms.viewMatrix
    * uniforms.modelMatrix
    * in.position;
  VertexOut out {
    .position = position,
    .keyPressed = keyPressed
  };
  return out;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]]
) {
  float weight = in.keyPressed ? 1 : 0;
  return float4(weight, weight, weight, 1);
}
