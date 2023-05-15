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
//  private var meshes: [GraphicsMesh]
  private var meshes: [MTKMesh]
  
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
    
    if let mdlMesh =
        asset.childObjects(of: MDLMesh.self).first as? MDLMesh {
      do {
        let newMesh = try MTKMesh(mesh: mdlMesh, device: device)
        self.meshes.append(newMesh)
      } catch {
        fatalError("Failed to load mesh.")
      }
    } else {
      fatalError("No mesh available.")
    }
    
    print("Configuration complete.")
  }
  
}

extension GraphicsModel : Renderable {
  func render(commandEncoder: MTLRenderCommandEncoder) {
    
    for mesh in self.meshes {

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
      
      commandEncoder.setVertexBuffer(
        mesh.vertexBuffers[0].buffer,
        offset: 0,
        index: 0
      )

      for submesh in mesh.submeshes {
        commandEncoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer.buffer,
          indexBufferOffset: submesh.indexBuffer.offset
        )
      }

    }
    
  }
}
