//
//  GraphicsModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

class GraphicsModel {
  
  public let name: String
  public var scale: Float
  public var position: simd_float3
  public var rotation: simd_float3
  private var colour: simd_float4
  private let assetURL: URL
  private var meshes: [MTKMesh]
  
  init(name: String) {
    self.name = name
    self.scale = 1
    self.position = simd_float3(0.0, 0.0, 0.0)
    self.rotation = simd_float3(0.0, 0.0, 0.0)
    self.colour   = simd_float4(0.0, 0.0, 0.0, 1.0)
    
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
  
  func setColour(colour: simd_float4) {
    self.colour = colour
  }
  
}

extension GraphicsModel : Renderable {
  func render(
    commandEncoder: MTLRenderCommandEncoder,
    uniforms vertex: Uniforms
  ) {
    
    var uniforms = vertex
    
    let translationMatrix = createTranslationMatrix(
      x: self.position.x,
      y: self.position.y,
      z: self.position.z
    )
    let rotationMatrix = createRotationMatrix(
      angleX: self.rotation.x,
      angleY: self.rotation.y,
      angleZ: self.rotation.z
    )
    uniforms.modelMatrix = translationMatrix * rotationMatrix
    uniforms.viewMatrix =
      createTranslationMatrix(x: 0.0, y: 0.0, z: -4.0).inverse
    
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: 11
    )
    
    commandEncoder.setVertexBytes(
      &self.colour,
      length: MemoryLayout<simd_float4>.stride,
      index: 12
    )
    
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
