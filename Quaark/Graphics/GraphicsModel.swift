//
//  GraphicsModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

class GraphicsModel {
  
  let name: String
  var colour: simd_float4
//  public var transforms: [Transform]
  var instances: [ModelInstance]
    // there can be multiple transforms because any model may have multiple instances
  private let assetURL: URL
  var meshes: [GraphicsMesh]
  
  let maxInstances: Int
  var currModuloInstance: Int
  var instancesBuffer: MTLBuffer?
  
  init(name: String, numInstances: Int = 1) {
    self.name = name
    self.instances = [ModelInstance(
      transform: Transform(),
      albedo: simd_float4(1, 1, 1, 1)
    )]
    self.colour = simd_float4(0, 0, 0, 1)
    
    self.maxInstances = 5
    self.currModuloInstance = 0
    
    guard let newAssetURL = Bundle.main.url(
      forResource: name,
      withExtension: nil
    ) else {
      fatalError("Model \(name) not found.")
    }
    self.assetURL = newAssetURL
    
    self.meshes = []
  }
  
//  init(url: String) {
//
//    let newAssetUrl = URL(fileURLWithPath: url)
//
//    guard FileManager.default.fileExists(atPath: newAssetUrl.path) else {
//      fatalError("File not found at \(newAssetUrl)")
//    }
//    do {
//        let fileExists = try newAssetUrl.checkResourceIsReachable()
//        if (!fileExists) {
//            fatalError("File \(url) not found.")
//        }
//    } catch {
//      fatalError("Error accessing file \(url).")
//    }
//
//    self.name = "DEFAULT NAME" // TODO: deal with this
//    self.transform = Transform()
//    self.colour = simd_float4(0.0, 0.0, 0.0, 1.0)
//    self.assetURL = newAssetUrl
//    self.meshes = []
//  }
  
  // ! TODO: this should be static
  func configureMeshes(device: MTLDevice) {
    print("Meshes for \(self.name) being configured...")
    
    let allocator = MTKMeshBufferAllocator(device: device)
    let meshDescriptor = MDLVertexDescriptor.defaultLayout
    let asset = MDLAsset(
      url: self.assetURL,
      vertexDescriptor: meshDescriptor,
      bufferAllocator: allocator
    )
    
    var mtkMeshes: [MTKMesh] = []
    let mdlMeshes =
      asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
    _ = mdlMeshes.map { mdlMesh in
      mtkMeshes.append(
        try! MTKMesh(
          mesh: mdlMesh,
          device: device
        )
      )
    }
    
    self.meshes = zip(mdlMeshes, mtkMeshes).map {
      GraphicsMesh(mdlMesh: $0.0, mtkMesh: $0.1)
    }
    
    self.instancesBuffer = self.createInstancesBuffer(device: device)
    
    print("Mesh configuration complete.")
  }
  
  func addInstance(
    transform: Transform = Transform(),
    albedo: simd_float4 = simd_float4(1, 0.3, 1, 1)
  ) {
    if self.instances.count < self.maxInstances {
      self.instances.append(ModelInstance(
        transform: transform,
        albedo: albedo
      ))
    } else {
      if self.currModuloInstance >= self.maxInstances {
        self.currModuloInstance = 0
      }
      self.instances[self.currModuloInstance] = ModelInstance(
        transform: transform,
        albedo: albedo
      )
      self.currModuloInstance += 1
    }
  }
  
  func createInstancesBuffer(
    device: MTLDevice
  ) -> MTLBuffer {
    let bufferSize = MemoryLayout<InstancesData>.stride * self.instances.count
    let instancesBuffer = device.makeBuffer(
      length: bufferSize,
      options: []
    )!
    
    var instancesData: [InstancesData] = []
    for instance in self.instances {
      let instanceData = InstancesData(
        modelMatrix: instance.transform.modelMatrix,
        normalMatrix: upperLeft(matrix: instance.transform.modelMatrix),
        albedo: instance.albedo
      )
      instancesData.append(instanceData)
    }
        
    memcpy(instancesBuffer.contents(), instancesData, bufferSize)
    
    return instancesBuffer
  }
  
}

extension GraphicsModel {
  func render(
    device: MTLDevice,
      // device is required for creating instances buffer. TODO: find a better method?
    commandEncoder: MTLRenderCommandEncoder,
    uniforms vertex: Uniforms,
    parameters fragment: Parameters
  ) {
    commandEncoder.pushDebugGroup(self.name)
    
    self.instancesBuffer = self.createInstancesBuffer(device: device)
    
    var uniforms = vertex
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
    
    commandEncoder.setVertexBuffer(
      instancesBuffer,
      offset: 0,
      index: InstancesBuffer.index
    )
    
    for mesh in self.meshes {
      for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
        commandEncoder.setVertexBuffer(
          vertexBuffer,
          offset: 0,
          index: index
        )
      }
      
      for submesh in mesh.submeshes {
        commandEncoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset,
          instanceCount: self.instances.count
        )
      }
    }
    
    commandEncoder.popDebugGroup()
  }
}

struct ModelInstance {
  var transform: Transform
  var albedo: simd_float4
  
  init(
    transform: Transform,
    albedo: simd_float4
  ) {
    self.transform = transform
    self.albedo = albedo
  }
}
