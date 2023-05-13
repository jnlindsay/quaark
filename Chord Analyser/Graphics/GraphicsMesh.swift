//
//  GraphicsMesh.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

struct GraphicsMesh {
  
  // Notice the design here. The _vertices_ of an entire mesh are given all at once,
  //   but the submeshes are defined via _indices_.
  
  let vertexBuffers: [MTLBuffer]
  let submeshes: [GraphicsSubmesh]
  
  init(mtkMesh: MTKMesh, mdlMesh: MDLMesh) {
    var newVertexBuffers: [MTLBuffer] = []
    for mtkMeshBuffer in mtkMesh.vertexBuffers {
      newVertexBuffers.append(mtkMeshBuffer.buffer)
    }
    self.vertexBuffers = newVertexBuffers
    
    self.submeshes =
      zip(
        mtkMesh.submeshes,
        mdlMesh.submeshes!
      ).map { mesh in
        GraphicsSubmesh(
          mtkSubmesh: mesh.0,
          mdlSubmesh: mesh.1 as! MDLSubmesh
        )
      }
  }
  
}
