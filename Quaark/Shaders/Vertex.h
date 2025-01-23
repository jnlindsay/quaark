//
//  Vertex.h
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

#ifndef Vertex_h
#define Vertex_h
#import "Common.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 normal [[attribute(Normal)]];
  float4 albedo;
  float3 worldPosition;
  float3 worldNormal;
};

#endif /* Vertex_h */
