//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
using namespace metal;
#import "../Metal/Common.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_main(
  const VertexIn in [[stage_in]]
) {
  float4 position = in.position;
  
  VertexOut out {
    .position = position,
  };
  
  return out;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]]
) {
  return float4(1, 1, 1, 1);
}
