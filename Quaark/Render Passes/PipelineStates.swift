//
//  PipelineStates.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

import MetalKit

enum PipelineStates {
  static func createPipelineState(
    device: MTLDevice,
    pipelineDescriptor: MTLRenderPipelineDescriptor
  ) -> MTLRenderPipelineState {
    let pipelineState: MTLRenderPipelineState
    do {
      pipelineState =
        try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }
  
  static func createGBufferPipelineState(
    renderer: Renderer,
    colourPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineState {
    let vertexFunction = renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = renderer.library.makeFunction(name: "fragment_gBuffer")
    
    // pipeline descriptor
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
                    // attachments
    pipelineDescriptor.colorAttachments[RenderTargetDefault.index].pixelFormat = .invalid
    pipelineDescriptor.colorAttachments[RenderTargetAlbedo.index].pixelFormat = .bgra8Unorm
    pipelineDescriptor.colorAttachments[RenderTargetNormal.index].pixelFormat = .rgba16Float
    pipelineDescriptor.colorAttachments[RenderTargetPosition.index].pixelFormat = .rgba16Float
    pipelineDescriptor.colorAttachments[RenderTargetBloom.index].pixelFormat = .bgra8Unorm
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor =
      MTLVertexDescriptor.defaultLayout
    
    return createPipelineState(
      device: renderer.device,
      pipelineDescriptor: pipelineDescriptor
    )
  }
  
  static func createSunLightPipelineState(
    renderer: Renderer,
    colourPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineState {
    let vertexFunction = renderer.library.makeFunction(name: "vertex_quad")
    let fragmentFunction = renderer.library.makeFunction(name: "fragment_deferredSun")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[RenderTargetDefault.index].pixelFormat = colourPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    return createPipelineState(
      device: renderer.device,
      pipelineDescriptor: pipelineDescriptor
    )
  }
  
  static func createPointLightPipelineState(
    renderer: Renderer,
    colourPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineState {
    let vertexFunction = renderer.library.makeFunction(name: "vertex_pointLight")
    let fragmentFunction = renderer.library.makeFunction(name: "fragment_pointLight")
    
    // pipeline descriptor
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
                     // attachments
    let attachment = pipelineDescriptor.colorAttachments[RenderTargetDefault.index]
    attachment?.pixelFormat = colourPixelFormat
    attachment?.isBlendingEnabled = true
    attachment?.rgbBlendOperation = .add
    attachment?.alphaBlendOperation = .add
    attachment?.sourceRGBBlendFactor = .one
    attachment?.sourceAlphaBlendFactor = .one
    attachment?.destinationRGBBlendFactor = .one
    attachment?.destinationAlphaBlendFactor = .zero
    attachment?.sourceRGBBlendFactor = .one
    attachment?.sourceAlphaBlendFactor = .one
    
    return createPipelineState(
      device: renderer.device,
      pipelineDescriptor: pipelineDescriptor
    )
  }
}
