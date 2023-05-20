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
  private var depthStencilState: MTLDepthStencilState
  private var world: GraphicsWorld
  private var uniforms: Uniforms
  private var parameters: Parameters
  var prevTime: Double

  init(metalView: MTKView, world: GraphicsWorld) {
    print("--- Renderer initialisation has begun. ---")
    
    // TODO: abstract each section into separate method
    
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
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
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
    
    // depth stencil state
    let depthStencilDescriptor = MTLDepthStencilDescriptor()
    depthStencilDescriptor.depthCompareFunction = .less
    depthStencilDescriptor.isDepthWriteEnabled = true
    if let depthStencilState = self.device.makeDepthStencilState(
      descriptor: depthStencilDescriptor
    ) {
      self.depthStencilState = depthStencilState
    } else {
      fatalError("Depth stencil state could not be created.")
    }
    
    // uniforms and parameters
    self.uniforms = Uniforms()
    self.parameters = Parameters()
    
    // world
    self.world = world
    
    // timer
    self.prevTime = CFAbsoluteTimeGetCurrent()
    
    // must be called after all variables have been initialised
    super.init()
    
    self.configureMeshes()
    self.world.renderer = self
    
    mtkView(
      metalView,
      drawableSizeWillChange: metalView.bounds.size
    )

    print("--- Renderer initialisation is complete. ---")
    
  }
  
  func configureMeshes() {
    for model in self.world.models {
      model.configureMeshes(device: self.device)
    }
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
    self.world.update(windowSize: size)
  }
  
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
    commandEncoder.setDepthStencilState(self.depthStencilState)
//    commandEncoder.setTriangleFillMode(.lines)
    
    // update world
    let currentTime = CFAbsoluteTimeGetCurrent()
    let deltaTime = Float(currentTime - self.prevTime)
    self.prevTime = currentTime
    self.world.update(deltaTime: deltaTime)
    
    // set uniforms
    self.uniforms.viewMatrix = self.world.mainCamera.viewMatrix
    self.uniforms.projectionMatrix = self.world.mainCamera.projectionMatrix
    self.parameters.lightCount = UInt32(self.world.lighting.lights.count)
    self.parameters.cameraPosition = self.world.mainCamera.position
      // Q: querying lightCount each time is inefficient?
    
    // lighting
    var lights = world.lighting.lights
    commandEncoder.setFragmentBytes(
      &lights,
      length: MemoryLayout<Light>.stride * lights.count,
      index: LightBuffer.index
    )
    
    // render models
    for model in self.world.models {
      model.render(
        commandEncoder: commandEncoder,
        uniforms: self.uniforms,
        parameters: self.parameters
      )
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
  func render(
    commandEncoder: MTLRenderCommandEncoder,
    uniforms: Uniforms,
    parameters: Parameters
  )
}
