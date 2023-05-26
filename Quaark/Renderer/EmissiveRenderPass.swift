////
////  EmissiveRenderPass.swift
////  Quaark
////
////  Created by Jeremy Lindsay on 26/5/2023.
////
//
//import MetalKit
//
//struct EmissiveRenderPass : RenderPass {
//  let label: String
//
//  weak var renderer: Renderer?
//  private let metalView: MTKView
//
//  var pipelineState: MTLRenderPipelineState?
//  var depthStencilState: MTLDepthStencilState?
//
//  var albedoTexture: MTLTexture?
//
//  init(
//    metalView: MTKView,
//    renderPassDescriptorFromView: Bool
//  ) {
//    self.label = "Emissive Render Pass"
//    self.metalView = metalView,
//    self.nonViewRenderPassDescriptor = renderPassDescriptorFromView ?
//      nil : MTLRenderPassDescriptor()
//  }
//  
//  mutating func initLate(
//    renderer: Renderer
//  ) {
//    self.renderer = renderer
//    
//    self.pipelineState = PipelineStates.createEmissivePipelineState(
//      renderer: renderer,
//      colourPixelFormat: self.metalView.colorPixelFormat
//    )
//    
//    self.depthStencilState = Self.buildDepthStencilState(device: renderer.device)
//  }
//  
//  mutating func resize(metalView: MTKView, size: CGSize) { }
//  
//  func draw(
//    commandBuffer: MTLCommandBuffer,
//    metalViewRenderPassDescriptor: MTLRenderPassDescriptor?,
//    world: GraphicsWorld,
//    uniforms: Uniforms,
//    parameters: Parameters
//  ) {
//    
//    
//    
//  }
//  
//}
