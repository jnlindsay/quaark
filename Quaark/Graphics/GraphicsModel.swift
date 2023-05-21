//
//  GraphicsModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

class GraphicsModel {
  
  public let name: String
  private var colour: simd_float4
  public var transform: Transform
  private let assetURL: URL
  private var meshes: [MTKMesh]
  
  init(name: String) {
    self.name = name
    self.transform = Transform()
    self.colour = simd_float4(0.0, 0.0, 0.0, 1.0)
    
    guard let newAssetURL = Bundle.main.url(
      forResource: name,
      withExtension: nil
    ) else {
      fatalError("Model \(name) not found.")
    }
    self.assetURL = newAssetURL
    
    self.meshes = []
  }
  
  init(url: String) {

    let newAssetUrl = URL(fileURLWithPath: url)

    guard FileManager.default.fileExists(atPath: newAssetUrl.path) else {
      fatalError("File not found at \(newAssetUrl)")
    }
    do {
        let fileExists = try newAssetUrl.checkResourceIsReachable()
        if (!fileExists) {
            fatalError("File \(url) not found.")
        }
    } catch {
      fatalError("Error accessing file \(url).")
    }
    
    self.name = "DEFAULT NAME" // TODO: deal with this
    self.transform = Transform()
    self.colour = simd_float4(0.0, 0.0, 0.0, 1.0)
    self.assetURL = newAssetUrl
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
    uniforms vertex: Uniforms,
    parameters fragment: Parameters
  ) {
    
    var uniforms = vertex
    uniforms.modelMatrix = self.transform.modelMatrix
    uniforms.normalMatrix = upperLeft(matrix: uniforms.modelMatrix)
    
    var parameters = fragment
    
    commandEncoder.setVertexBytes(
      &self.colour,
      length: MemoryLayout<simd_float4>.stride,
      index: ColourBuffer.index
    )
    
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index
    )
    
    commandEncoder.setFragmentBytes(
      &parameters,
      length: MemoryLayout<Parameters>.stride,
      index: ParametersBuffer.index
    )
    
    for mesh in self.meshes {
      commandEncoder.setVertexBuffer(
        mesh.vertexBuffers[0].buffer,
        offset: 0,
        index: VertexBuffer.index
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
