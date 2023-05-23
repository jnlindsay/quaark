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
  var albedoTexture: MTLTexture?
  var normalTexture: MTLTexture?
  var positionTexture: MTLTexture?
  var depthTexture: MTLTexture?
  
  init(renderer: Renderer, metalView: MTKView) {
    self.label = "G-Buffer Render Pass"
    self.renderer = renderer
    self.pipelineState = PipelineStates.createGBufferPipelineState(
      renderer: renderer,
      colourPixelFormat: metalView.colorPixelFormat
    )
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
    self.renderPassDescriptor = MTLRenderPassDescriptor()
  }
  
  mutating func resize(metalView: MTKView, size: CGSize) {
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
  }
  
  func draw(
    commandBuffer: MTLCommandBuffer,
    world: GraphicsWorld,
    uniforms: Uniforms,
    parameters: Parameters
  ) {
    let textures = [
      self.albedoTexture,
      self.normalTexture,
      self.positionTexture
    ]
    let textureIndices = [
      RenderTargetAlbedo,
      RenderTargetNormal,
      RenderTargetPosition
    ]
    
    for (index, texture) in textures.enumerated() {
      let attachment =
        self.renderPassDescriptor?.colorAttachments[textureIndices[index].index]
      attachment?.texture = texture
      attachment?.loadAction = .clear
      attachment?.storeAction = .store
      attachment?.clearColor =
        MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
    }
    self.renderPassDescriptor?.depthAttachment.texture = self.depthTexture
    self.renderPassDescriptor?.depthAttachment.storeAction = .dontCare
    
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
        commandEncoder: commandEncoder,
        uniforms: uniforms,
        parameters: parameters
      )
    }
    
    commandEncoder.endEncoding()
  }
  
}
