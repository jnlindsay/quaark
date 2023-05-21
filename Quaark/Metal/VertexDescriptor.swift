//
//  VertexDescriptor.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/5/2023.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(MDLVertexDescriptor.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()
    var offset = 0

    // attribute 0: position
    vertexDescriptor.attributes[Position.index] =
      MDLVertexAttribute(
        name: MDLVertexAttributePosition,
        format: .float3,
        offset: 0,
        bufferIndex: 0
      )
    offset += MemoryLayout<simd_float3>.stride
    
    // attribute 1: normal
    vertexDescriptor.attributes[Normal.index] =
      MDLVertexAttribute(
        name: MDLVertexAttributeNormal,
        format: .float3,
        offset: offset,
        bufferIndex: 0
      )
    offset += MemoryLayout<simd_float3>.stride
    
    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)    
    return vertexDescriptor
  }
}

extension MetalAttributes {
  var index: Int {
    return Int(rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    return Int(rawValue)
  }
}
