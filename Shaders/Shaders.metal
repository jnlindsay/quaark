//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
using namespace metal;

//vertex float4 vertex_main() {
//  return float4(0, 0, 1, 1);
//}

vertex float4 vertex_main(
  constant packed_float3 *vertices [[buffer(0)]],
  constant float &timer [[buffer(11)]],
  uint vertexID [[vertex_id]]
) {
  float4 position = float4(vertices[vertexID], 1);
  position.y += timer;
  return position;
}

fragment float4 fragment_main() {
  return float4(0, 0, 1, 1);
}
