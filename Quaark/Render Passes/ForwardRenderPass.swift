//
//  ForwardRenderPass.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

import MetalKit

struct ForwardRenderPass : RenderPass {
  let label: String
  weak var renderer: Renderer?
  var renderPassDescriptor: MTLRenderPassDescriptor?
  var pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?
  
  init(renderer: Renderer, metalView: MTKView) {
    self.label = "Forward Render Pass"
    self.renderer = renderer
    self.pipelineState = PipelineStates.createForwardPipelineState(
      renderer: renderer,
      colourPixelFormat: metalView.colorPixelFormat
    )
    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
  }
  
  mutating func resize(metalView: MTKView, size: CGSize) { }
  
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
    commandEncoder.setRenderPipelineState(self.pipelineState)
//    commandEncoder.setTriangleFillMode(.lines)
    
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
