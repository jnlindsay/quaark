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
  private let metalView: MTKView
  
  var nonViewRenderPassDescriptor: MTLRenderPassDescriptor?
  
  var sunLightPipelineState: MTLRenderPipelineState?
  var pointLightPipelineState: MTLRenderPipelineState?
  var depthStencilState: MTLDepthStencilState?
  
  weak var albedoTexture: MTLTexture?
  weak var normalTexture: MTLTexture?
  weak var positionTexture: MTLTexture?
  weak var bloomTexture: MTLTexture?
  
  init(
    metalView: MTKView,
    renderPassDescriptorFromView: Bool
  ) {
    self.label = "Lighting Render Pass"
    self.metalView = metalView
    self.nonViewRenderPassDescriptor = renderPassDescriptorFromView ?
      nil : MTLRenderPassDescriptor()
  }
  
  mutating func initLate(
    renderer: Renderer
  ) {
    self.renderer = renderer
    
    self.sunLightPipelineState = PipelineStates.createSunLightPipelineState(
      renderer: renderer,
      colourPixelFormat: self.metalView.colorPixelFormat
    )
    self.pointLightPipelineState = PipelineStates.createPointLightPipelineState(
      renderer: renderer,
      colourPixelFormat: self.metalView.colorPixelFormat
    )
    
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
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
    metalViewRenderPassDescriptor: MTLRenderPassDescriptor?,
    world: GraphicsWorld,
    uniforms: Uniforms,
    parameters: Parameters
  ) {
    
    // render pass descriptor
    var renderPassDescriptor: MTLRenderPassDescriptor
    if let temp = self.nonViewRenderPassDescriptor {
      renderPassDescriptor = temp
    } else if let temp = metalViewRenderPassDescriptor {
      renderPassDescriptor = temp
    } else {
      fatalError("Render pass descriptor could not be obtained.")
    }
    
    // render command encoder
    guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(
      descriptor: renderPassDescriptor
    ) else {
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
    if let sunLightPipelineState = self.sunLightPipelineState {
      commandEncoder.setRenderPipelineState(sunLightPipelineState)
    } else {
      fatalError("Pipeline state not set for sun light in LightingRenderPass.")
    }
    
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
      index: LightBuffer.index
    )
    commandEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6
    )
    
    commandEncoder.popDebugGroup()
  }
  
  // TODO: should be plural `drawPointLights`
  func drawPointLight(
    commandEncoder: MTLRenderCommandEncoder,
    world: GraphicsWorld,
    uniforms vertex: Uniforms,
    parameters: Parameters
  ) {
    commandEncoder.pushDebugGroup("Point lights")
    
    var uniforms = vertex
    
    if let pointLightPipelineState = self.pointLightPipelineState {
      commandEncoder.setRenderPipelineState(pointLightPipelineState)
    } else {
      fatalError("Pipeline state not set for point light in LightingRenderPass.")
    }
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index
    )
    commandEncoder.setVertexBuffer(
      world.lighting.pointLightsBuffer,
      offset: 0,
      index: LightBuffer.index
    )
    commandEncoder.setFragmentBuffer(
      world.lighting.pointLightsBuffer,
      offset: 0,
      index: LightBuffer.index
    )
    commandEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6,
      instanceCount: world.lighting.pointLights.count
    )
    
    commandEncoder.popDebugGroup()
  }
}
