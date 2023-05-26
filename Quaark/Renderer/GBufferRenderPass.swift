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
  private let metalView: MTKView
  
  var nonViewRenderPassDescriptor: MTLRenderPassDescriptor?
  
  var pipelineState: MTLRenderPipelineState?
  var depthStencilState: MTLDepthStencilState?

  var albedoTexture: MTLTexture?
  var normalTexture: MTLTexture?
  var positionTexture: MTLTexture?
  var depthTexture: MTLTexture?
  var bloomTexture: MTLTexture?
  
  init(
    metalView: MTKView,
    renderPassDescriptorFromView: Bool
  ) {
    self.label = "G-Buffer Render Pass"
    self.metalView = metalView
    self.nonViewRenderPassDescriptor = renderPassDescriptorFromView ?
      nil : MTLRenderPassDescriptor()
  }
  
  mutating func initLate(
    renderer: Renderer
  ) {
    self.renderer = renderer
    self.pipelineState = PipelineStates.createGBufferPipelineState(
      renderer: renderer,
      colourPixelFormat: self.metalView.colorPixelFormat
    )
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
  }
  
  mutating func resize(metalView: MTKView, size: CGSize) {
    self.albedoTexture = Self.makeTexture(
      label: "Albedo Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .bgra8Unorm
    )
    self.normalTexture = Self.makeTexture(
      label: "Normal Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .rgba16Float
    )
    self.positionTexture = Self.makeTexture(
      label: "Position Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .rgba16Float
    )
    self.depthTexture = Self.makeTexture(
      label: "Depth Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .depth32Float
    )
    self.bloomTexture = Self.makeTexture(
      label: "Bloom Texture",
      size: size,
      device: self.renderer!.device,
      pixelFormat: .bgra8Unorm
    )
  }
  
  func draw(
    commandBuffer: MTLCommandBuffer,
    metalView: MTKView,
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

    let textures: [MTLTexture?] = [
      self.albedoTexture,
      self.normalTexture,
      self.positionTexture,
      self.bloomTexture
    ]
    
    let textureIndices = [
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
    if let pipelineState = self.pipelineState {
      commandEncoder.setRenderPipelineState(pipelineState)
    } else {
      fatalError("Pipeline state not set for GBufferRenderPass.")
    }

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
    
    // BLIT
    
    guard
      self.albedoTexture!.width == metalView.currentDrawable!.texture.width,
      self.albedoTexture!.height == metalView.currentDrawable!.texture.height
    else {
      return
    }
    
    guard let blitEncoder = commandBuffer.makeBlitCommandEncoder()
      else { return }
    let origin = MTLOrigin(x: 0, y: 0, z: 0)
    let size = MTLSize(
      width: self.albedoTexture!.width,
      height: self.albedoTexture!.height,
      depth: 1
    )
    blitEncoder.copy(
      from: self.albedoTexture!,
      sourceSlice: 0,
      sourceLevel: 0,
      sourceOrigin: origin,
      sourceSize: size,
      to: metalView.currentDrawable!.texture,
      destinationSlice: 0,
      destinationLevel: 0,
      destinationOrigin: origin
    )
    blitEncoder.endEncoding()
  }
  
}
