//
//  GraphicsMesh.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

//import MetalKit
//
//struct GraphicsMesh {
//  
//  // Notice the design here. The _vertices_ of an entire mesh are given all at once,
//  //   but the submeshes are defined via _indices_.
//  
//  let vertexBuffers: [MTLBuffer]
//  let submeshes: [GraphicsSubmesh]
//  
//  init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
//    var newVertexBuffers: [MTLBuffer] = []
//    for mtkMeshBuffer in mtkMesh.vertexBuffers {
//      newVertexBuffers.append(mtkMeshBuffer.buffer)
//    }
//    self.vertexBuffers = newVertexBuffers
//    
//    self.submeshes =
//      zip(
//        mdlMesh.submeshes!,
//        mtkMesh.submeshes
//      ).map { mesh in
//        GraphicsSubmesh(
//          mdlSubmesh: mesh.0 as! MDLSubmesh,
//          mtkSubmesh: mesh.1
//        )
//      }
//  }
//  
//}
