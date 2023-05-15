//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_main(
  const VertexIn in [[stage_in]]
) {
  float4 position = in.position;
  return position;
}

fragment float4 fragment_main() {
  return float4(1, 1, 1, 1);
}


