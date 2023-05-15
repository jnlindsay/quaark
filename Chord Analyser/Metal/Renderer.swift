//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import simd
import MetalKit

class Renderer : NSObject {
  private var device: MTLDevice
    /* Do not under any circumstances change this declaration of `device`.
       It should be accessed only in this class and its derivatives. */
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private let pipelineState: MTLRenderPipelineState
  private var world: GraphicsWorld
//  var timer: Float = 0

  init(metalView: MTKView, world: GraphicsWorld) {
    print("--- Renderer initialisation has begun. ---")
    
    // device
    if let newDevice = MTLCreateSystemDefaultDevice() {
      self.device = newDevice
      metalView.device = newDevice
    } else {
      fatalError("Renderer device could not be created.")
    }
    
    // command queue
    if let newCommandQueue = self.device.makeCommandQueue() {
      self.commandQueue = newCommandQueue
    } else {
      fatalError("Command queue could not be created.")
    }

    // shader library
    if let newLibrary = self.device.makeDefaultLibrary() {
      self.library = newLibrary
    } else {
      fatalError("Shader library could not be created.")
    }
    let vertexFunction = self.library.makeFunction(name: "vertex_main")
    let fragmentFunction = self.library.makeFunction(name: "fragment_main")
    
    // pipeline state
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat =
      metalView.colorPixelFormat
    do {
      pipelineDescriptor.vertexDescriptor =
        MTLVertexDescriptor.defaultLayout
      self.pipelineState =
        try self.device.makeRenderPipelineState(
          descriptor: pipelineDescriptor
        )
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    // configure GraphicsWorld meshes
    self.world = world
    for model in self.world.models {
      model.configureMeshes(device: self.device)
    }
    
    super.init()
    mtkView(
      metalView,
      drawableSizeWillChange: metalView.bounds.size
    )

    print("--- Renderer initialisation is complete. ---")
    
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {}
  
  func draw(in metalView: MTKView) {
      
    guard
      let commandBuffer = self.commandQueue.makeCommandBuffer()
    else {
      fatalError("Command buffer could not be created.")
    }
    
    guard
      let renderPassDescriptor = metalView.currentRenderPassDescriptor
    else {
      fatalError("Render pass descriptor could not be obtained.")
    }
    
    guard
      let commandEncoder = commandBuffer.makeRenderCommandEncoder(
          descriptor: renderPassDescriptor
        )
    else {
      fatalError("Command encoder could not be created.")
    }
    
    commandEncoder.setRenderPipelineState(self.pipelineState)
    
//    timer += 0.005
//    var currentTime = sin(timer)
//    commandEncoder.setVertexBytes(
//      &currentTime,
//      length: MemoryLayout<Float>.stride,
//      index: 11
//    )
    
    for model in self.world.models {
      model.render(commandEncoder: commandEncoder)
    }

    commandEncoder.endEncoding()

    guard let drawable = metalView.currentDrawable else {
      print("Renderer.swift: drawable not obtained.")
      return
    }
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
      
  }
}

protocol Renderable {
  func render(commandEncoder: MTLRenderCommandEncoder)
}
