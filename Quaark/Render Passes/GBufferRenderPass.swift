//
//  ForwardRenderPass.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

import MetalKit

struct GBufferRenderPass : RenderPass {

  let label: String
  weak var renderer: Renderer?
  var renderPassDescriptor: MTLRenderPassDescriptor?
  
  var pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  
  var defaultTexture: MTLTexture?
  var albedoTexture: MTLTexture?
  var normalTexture: MTLTexture?
  var positionTexture: MTLTexture?
  var depthTexture: MTLTexture?
  var bloomTexture: MTLTexture?
  
  init(renderer: Renderer, metalView: MTKView) {
    self.label = "G-Buffer Render Pass"
    self.renderer = renderer
    self.pipelineState = PipelineStates.createGBufferPipelineState(
      renderer: renderer,
      colourPixelFormat: metalView.colorPixelFormat
    )
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
//    self.renderPassDescriptor = MTLRenderPassDescriptor()
  }
  
  mutating func resize(metalView: MTKView, size: CGSize) {
    defaultTexture = Self.makeTexture(
      label: "Default Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .bgra8Unorm
    )
    albedoTexture = Self.makeTexture(
      label: "Albedo Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .bgra8Unorm
    )
    normalTexture = Self.makeTexture(
      label: "Normal Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .rgba16Float
    )
    positionTexture = Self.makeTexture(
      label: "Position Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .rgba16Float
    )
    depthTexture = Self.makeTexture(
      label: "Depth Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .depth32Float
    )
    bloomTexture = Self.makeTexture(
      label: "Bloom Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .bgra8Unorm
    )
  }
  
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
    
    let textures = [
      self.defaultTexture,
      self.albedoTexture,
      self.normalTexture,
      self.positionTexture,
      self.bloomTexture
    ]
    let textureIndices = [
      RenderTargetDefault,
      RenderTargetAlbedo,
      RenderTargetNormal,
      RenderTargetPosition,
      RenderTargetBloom
    ]
    
    for (index, texture) in textures.enumerated() {
      let attachment =
        renderPassDescriptor.colorAttachments[textureIndices[index].index]
      attachment?.texture = texture
      attachment?.loadAction = .clear
      attachment?.storeAction = .store
      attachment?.clearColor =
        MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    renderPassDescriptor.depthAttachment.texture = self.depthTexture
    renderPassDescriptor.depthAttachment.storeAction = .dontCare
    
    commandEncoder.label = self.label
    commandEncoder.setDepthStencilState(self.depthStencilState)
    commandEncoder.setRenderPipelineState(self.pipelineState)
    
    // lighting
    var lights = world.lighting.lights
    commandEncoder.setFragmentBytes(
      &lights,
      length: MemoryLayout<Light>.stride * lights.count,
      index: LightBuffer.index
    )
    
    // render models
    for model in world.models {
      model.render(
        device: self.renderer!.device,
        commandEncoder: commandEncoder,
        uniforms: uniforms,
        parameters: parameters
      )
    }
    
    commandEncoder.endEncoding()
  }
  
}
