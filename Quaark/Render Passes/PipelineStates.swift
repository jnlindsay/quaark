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
  
  static func createForwardPipelineState(
    renderer: Renderer,
    colourPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineState {
    let vertexFunction = renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = renderer.library.makeFunction(name: "fragment_main")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = colourPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
    return createPipelineState(
      device: renderer.device,
      pipelineDescriptor: pipelineDescriptor
    )
  }
}
