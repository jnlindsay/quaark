//
//  Shaders.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/5/2023.
//

#include <metal_stdlib>
using namespace metal;

struct Colour {
  float red;
  float green;
  float blue;
};

struct VertexOut {
  float4 position [[position]];
  float red;
  float green;
  float blue;
};

vertex VertexOut vertex_main(
  constant packed_float3 *vertices [[buffer(0)]],
  constant ushort *indices [[buffer(1)]],
  constant Colour *colour [[buffer(2)]],
  constant float &timer [[buffer(11)]],
  uint vertexID [[vertex_id]]
) {
  ushort index = indices[vertexID];
  float4 position = float4(vertices[index], 1);
//  position.y += timer;
//  return position;
  VertexOut out {
    .position = position,
    .red = colour->red,
    .green = colour->green,
    .blue = colour->blue
  };
  return out;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]]
) {
//  float weight;
//  in.position.x < 200 ? weight = 0 : weight = 1;
  return float4(in.red, in.green, in.blue, 1);
//  return float4(0, 0, 1, 1);
}
