//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import Foundation
import simd
import MetalKit

struct Colour {
  var red:   Float
  var green: Float
  var blue:  Float

  init() {
    red = 0
    green = 0
    blue = 1
  }
}

class Renderer : NSObject {
    
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary!
  private let renderPipelineState: MTLRenderPipelineState!
  private let keyboardModel: KeyboardModel
  var timer: Float = 0
  var rectangleColour = Colour()

  // ! WARNING: DODGY CODE
//  lazy var quads: Population = {
//    Population(numObjects: 20, device: device, scale: 0.05)
//  }()
  private var world = World()
  
  init(mtkView: MTKView, keyboardModel: KeyboardModel) {
    self.device = mtkView.device!
    self.commandQueue = device.makeCommandQueue()!
    self.keyboardModel = keyboardModel
    
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
    
    // world
    world.populatePrimitive(numObjects: 20, device: device, scale: 0.05)
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
    
    let commandEncoder: MTLRenderCommandEncoder =
      commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    
    timer += 0.005
    var currentTime = sin(timer)
    commandEncoder.setVertexBytes(
      &currentTime,
      length: MemoryLayout<Float>.stride,
      index: 11
    )
    
    // ! WARNING: dodgy for loop; get rid and use vertex descriptors instead
    for quad in self.world.populations[0].quads {
      commandEncoder.setVertexBuffer(
        quad.vertexBuffer,
        offset: 0,
        index: 0
      )
      
      commandEncoder.setVertexBuffer(
        quad.indexBuffer,
        offset: 0,
        index: 1
      )
      
      //    rectangleColour.red = abs(sin(timer))
      rectangleColour.red = keyboardModel.getNotesOnOff(59) ? 1 : 0
      commandEncoder.setVertexBytes(
        &rectangleColour,
        length: MemoryLayout<Colour>.stride,
        index: 2
      )
      
      commandEncoder.setRenderPipelineState(renderPipelineState)
      
      // draw
      commandEncoder.drawPrimitives(
        type: .triangle,
        vertexStart: 0,
        vertexCount: quad.indices.count
      )
    }
  
    commandEncoder.endEncoding()

    // Get the drawable that will be presented at the end of the frame
    let drawable: MTLDrawable = mtkView.currentDrawable!
    
    // Request that the drawable texture be presented by the windowing system once drawing is done
    commandBuffer.present(drawable)
    commandBuffer.commit()
      
  }
}
