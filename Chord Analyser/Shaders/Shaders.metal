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

vertex float4 vertex_main(
  VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(11)]]
) {
  float4 position =
      uniforms.projectionMatrix
    * uniforms.viewMatrix
    * uniforms.modelMatrix
    * in.position;
  return position;
}

fragment float4 fragment_main() {
  return float4(1, 1, 1, 1);
}


