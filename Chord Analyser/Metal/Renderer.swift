//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import simd
import MetalKit

class Renderer : NSObject, MIDIListener {
  private var device: MTLDevice
    /* Do not under any circumstances change this declaration of `device`.
       It should be accessed only in this class and its derivatives. */
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private let pipelineState: MTLRenderPipelineState
  private var world: GraphicsWorld
  private var uniforms: Uniforms
  var timer: Float
  
  // ! WARNING: BAD CODE
  private var keyPressed: Bool = false

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
    
    // uniforms
    self.uniforms = Uniforms()
    
    // configure GraphicsWorld meshes
    self.world = world
    for model in self.world.models {
      model.configureMeshes(device: self.device)
    }
    
    self.timer = 0
    
    // must be called after all variables have been initialised
    super.init()
    
    // configure uniforms
    self.configureUniforms()
    
    mtkView(
      metalView,
      drawableSizeWillChange: metalView.bounds.size
    )

    print("--- Renderer initialisation is complete. ---")
    
  }
  
  func configureUniforms() {
    let translationMatrix = createTranslationMatrix(
      x:  0.5,
      y: -0.4,
      z:  0.0
    )
    let rotationMatrix = createRotationMatrix(
      angleX: 0.0,
      angleY: 0.0,
      angleZ: Float(45).degreesToRadians
    )
    self.uniforms.modelMatrix = translationMatrix * rotationMatrix
    self.uniforms.viewMatrix =
      createTranslationMatrix(x: 0.5, y: 0.0, z: 0.0).inverse
  }
  
  func handleMIDIEvent() {
    self.keyPressed = self.keyPressed ? false : true
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
    
    // update projection matrix
    let aspectRatio =
      Float(mtkView.bounds.width) / Float(mtkView.bounds.height)
    let projectionMatrix = createProjectionMatrix(
      projectionFOV: Float(45).degreesToRadians,
      nearPlane: 0.1,
      farPlane: 100,
      aspectRatio: aspectRatio
    )
    self.uniforms.projectionMatrix = projectionMatrix
    
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
//    commandEncoder.setTriangleFillMode(.lines)
    commandEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: 11
    )
//    var keyPressed: Bool = true
    commandEncoder.setVertexBytes(
      &self.keyPressed,
      length: MemoryLayout<Bool>.stride,
      index: 12
    )
    
    // timer
    timer += 0.005
  
    // HACKY CODE START -----------------------
    
    // rotate model around z axis
    let translationMatrix = createTranslationMatrix(
      x:  0.0,
      y: -0.6, // NOTE: manually made to match initialisation value
      z:  0.0
    )
    let rotationMatrix = createRotationMatrix(
      angleX: 0.0,
      angleY: sin(timer),
      angleZ: 0.0
    )
    uniforms.modelMatrix = translationMatrix * rotationMatrix
    uniforms.viewMatrix = createTranslationMatrix(
      x: 0.0, y: 0.0, z: -3
    ).inverse
    
    // HACKY CODE END ----------------------------
    
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
