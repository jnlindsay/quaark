//
//  LightingRenderPass.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

import MetalKit

struct LightingRenderPass : RenderPass {
  let label: String
  weak var renderer: Renderer?
  var renderPassDescriptor: MTLRenderPassDescriptor?
  
  var sunLightPipelineState: MTLRenderPipelineState
  var pointLightPipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  
  weak var albedoTexture: MTLTexture?
  weak var normalTexture: MTLTexture?
  weak var positionTexture: MTLTexture?
  
  var icosphere: GraphicsModel
  
  init(renderer: Renderer, metalView: MTKView) {
    self.label = "Lighting Render Pass"
    self.renderer = renderer
    self.sunLightPipelineState = PipelineStates.createSunLightPipelineState(
      renderer: renderer,
      colourPixelFormat: metalView.colorPixelFormat
    )
    self.pointLightPipelineState = PipelineStates.createPointLightPipelineState(
      renderer: renderer,
      colourPixelFormat: metalView.colorPixelFormat
    )
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
    self.icosphere = GraphicsModel(name: "icosphere.obj")
    self.icosphere.transform.scale = 10
    self.icosphere.configureMeshes(device: renderer.device)
      // TODO: above needs to be fixed
  }
  
  static func buildDepthStencilState(
    device: MTLDevice
  ) -> MTLDepthStencilState? {
    let stencilDescriptor = MTLDepthStencilDescriptor()
    stencilDescriptor.isDepthWriteEnabled = false
      // CRUCIAL: setting `.isDepthWriteEnabled` to `false` is what makes this stencil different from the 'usual' stencil state builder
    return device.makeDepthStencilState(descriptor: stencilDescriptor)
  }
  
  func resize(metalView: MTKView, size: CGSize) { }
  
  func draw(
    commandBuffer: MTLCommandBuffer,
    world: GraphicsWorld,
    uniforms: Uniforms,
    parameters: Parameters
  ) {
    // render pass descriptor
    guard
      let renderPassDescriptor = self.renderPassDescriptor
    else {
      fatalError("Render pass descriptor could not be obtained.")
    }
    
    // render command encoder
    guard
      let commandEncoder = commandBuffer.makeRenderCommandEncoder(
          descriptor: renderPassDescriptor
        )
    else {
      fatalError("Command encoder could not be created.")
    }
    commandEncoder.label = self.label
    commandEncoder.setDepthStencilState(self.depthStencilState)
    
    var uniforms = uniforms
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index
    )
    commandEncoder.setFragmentTexture(
      albedoTexture,
      index: BaseColourTexture.index
    )
    commandEncoder.setFragmentTexture(
      normalTexture,
      index: NormalTexture.index
    )
    commandEncoder.setFragmentTexture(
      positionTexture,
      index: PositionTexture.index
    )
    
    drawSunLight(
      commandEncoder: commandEncoder,
      world: world,
      parameters: parameters
    )
    
    drawPointLight(
      commandEncoder: commandEncoder,
      world: world,
      uniforms: uniforms,
      parameters: parameters
    )
    
    commandEncoder.endEncoding()
  }
  
  func drawSunLight(
    commandEncoder: MTLRenderCommandEncoder,
    world: GraphicsWorld,
    parameters: Parameters
  ) {
    commandEncoder.pushDebugGroup("Sun Light")
    commandEncoder.setRenderPipelineState(self.sunLightPipelineState)
    
    var parameters = parameters
    parameters.lightCount = UInt32(world.lighting.sunLights.count)
    
    commandEncoder.setFragmentBytes(
      &parameters,
      length: MemoryLayout<Parameters>.stride,
      index: ParametersBuffer.index
    )
    commandEncoder.setFragmentBuffer(
      world.lighting.sunLightsBuffer,
      offset: 0,
      index: LightBuffer.index)
    commandEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6)
    
    commandEncoder.popDebugGroup()
  }
  
  func drawPointLight(
    commandEncoder: MTLRenderCommandEncoder,
    world: GraphicsWorld,
    uniforms vertex: Uniforms,
    parameters: Parameters
  ) {
    var uniforms = vertex
    uniforms.modelMatrix = self.icosphere.transform.modelMatrix
    
    commandEncoder.pushDebugGroup("Point lights")
    commandEncoder.setRenderPipelineState(self.pointLightPipelineState)
    commandEncoder.setVertexBuffer(
      world.lighting.pointLightsBuffer,
      offset: 0,
      index: LightBuffer.index
    )
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index
    )
    commandEncoder.setFragmentBuffer(
      world.lighting.pointLightsBuffer,
      offset: 0,
      index: LightBuffer.index
    )

    guard let mesh = self.icosphere.meshes.first
    else {
      print("MESH NOT OBTAINED")
      return
    }
    guard let submesh = mesh.submeshes.first
    else {
      print("SUBMESH NOT OBTAINED")
      return
    }

    for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
      commandEncoder.setVertexBuffer(
        vertexBuffer,
        offset: 0,
        index: index
      )
    }

    commandEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: submesh.indexCount,
      indexType: submesh.indexType,
      indexBuffer: submesh.indexBuffer,
      indexBufferOffset: submesh.indexBufferOffset,
      instanceCount: world.lighting.pointLights.count
    )
    
    commandEncoder.popDebugGroup()
  }
}
