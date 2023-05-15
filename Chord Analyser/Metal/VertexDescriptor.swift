//
//  VertexDescriptor.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/5/2023.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()

    vertexDescriptor.attributes[Position.index] =
      MDLVertexAttribute(
        name: MDLVertexAttributePosition,
        format: .float3,
        offset: 0,
        bufferIndex: VertexBuffer.index
      )

    return vertexDescriptor
  }
}

extension Attributes {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}
