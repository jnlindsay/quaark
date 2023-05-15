//
//  GraphicsModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

class GraphicsModel {
  public let name: String
  private let assetURL: URL
  private var meshes: [GraphicsMesh]
  
  init(name: String) {
    self.name = name
    
    guard let newAssetURL = Bundle.main.url(
      forResource: name,
      withExtension: nil
    ) else {
      fatalError("Model \(name) not found.")
    }
    self.assetURL = newAssetURL
    
    self.meshes = []
  }
  
  func configureMeshes(device: MTLDevice) {
    print("Meshes for \(self.name) being configured...")
    
    let allocator = MTKMeshBufferAllocator(device: device)
    let asset = MDLAsset(
      url: self.assetURL,
      vertexDescriptor: .defaultLayout,
      bufferAllocator: allocator
    )
    let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(
      asset: asset,
      device: device
    )
    for zippedMesh in zip(mdlMeshes, mtkMeshes) {
      self.meshes.append(GraphicsMesh(
        mdlMesh: zippedMesh.0,
        mtkMesh: zippedMesh.1
      ))
    }
    
    print("Configuration complete.")
  }
  
}

extension GraphicsModel : Renderable {
  func render(commandEncoder: MTLRenderCommandEncoder) {
    
    print("Rendered!")
    
//    for mesh in self.meshes {
//
//      /*
//       ! WARNING: BUG PRONE. The number of vertex buffers here doesn't
//          seem to be fixed. Refer to GPU programming books to learn about
//          pricely how (and how many) buffers are created. There is a concern
//          that certain indices could be overwritten by the following `for`
//          loop.
//
//          Specifically, investigate:
//            - MTKMesh.newMeshes(asset:device:)
//            - MTKMeshBufferAllocator
//            - MDLAsset(url:vertexDescriptor:bufferAllocator:)
//            - MDLMesh, MTKMesh
//            - MTLBuffer
//      */
//      for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
//        commandEncoder.setVertexBuffer(
//          vertexBuffer,
//          offset: 0,
//          index: index)
//      }
//
//      for submesh in mesh.submeshes {
//        commandEncoder.drawIndexedPrimitives(
//          type: .triangle,
//          indexCount: submesh.indexCount,
//          indexType: submesh.indexType,
//          indexBuffer: submesh.indexBuffer,
//          indexBufferOffset: submesh.indexBufferOffset
//        )
//      }
//
//    }
    
  }
}
