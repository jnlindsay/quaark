//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import Foundation
import simd
import MetalKit

class Renderer : NSObject {
    
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary!
  private let renderPipelineState: MTLRenderPipelineState!
  var timer: Float = 0

  // ! WARNING: DODGY CODE
  lazy var quad: Quad = {
    Quad(device: self.device, scale: 0.8)
  }()
  
  init(mtkView: MTKView) {
    self.device = mtkView.device!
    self.commandQueue = device.makeCommandQueue()!
    
    // shaders
    self.library = device.makeDefaultLibrary()
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")
    
    // pipeline state
    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
    renderPipelineDescriptor.vertexFunction = vertexFunction
    renderPipelineDescriptor.fragmentFunction = fragmentFunction
    renderPipelineDescriptor.colorAttachments[0].pixelFormat =
      mtkView.colorPixelFormat
    do {
      renderPipelineState =
      try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {}
  
  func draw(in mtkView: MTKView) {
      
    // The render pass descriptor references the texture into which Metal should draw
    guard let renderPassDescriptor: MTLRenderPassDescriptor =
      mtkView.currentRenderPassDescriptor else { return }
      
    let commandBuffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!
    
    // Create a render pass and immediately end encoding, causing the drawable to be cleared
    let commandEncoder: MTLRenderCommandEncoder =
      commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    
    timer += 0.005
    var currentTime = sin(timer)
    commandEncoder.setVertexBytes(
      &currentTime,
      length: MemoryLayout<Float>.stride,
      index: 11
    )
    commandEncoder.setRenderPipelineState(renderPipelineState)
  
    // drawing occurs here...
    commandEncoder.setVertexBuffer(
      quad.vertexBuffer,
      offset: 0,
      index: 0
    )
    
    commandEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: quad.vertices.count
    )
  
    commandEncoder.endEncoding()

    // Get the drawable that will be presented at the end of the frame
    let drawable: MTLDrawable = mtkView.currentDrawable!
    
    // Request that the drawable texture be presented by the windowing system once drawing is done
    commandBuffer.present(drawable)
    commandBuffer.commit()
      
  }
}
