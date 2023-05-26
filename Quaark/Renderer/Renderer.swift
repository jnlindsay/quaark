//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import simd
import SwiftUI
import MetalKit

class Renderer : NSObject {
  @ObservedObject var settings: Settings
  
          var device: MTLDevice
  private let commandQueue: MTLCommandQueue
          let library: MTLLibrary
  private var world: GraphicsWorld
  private var uniforms: Uniforms
  private var parameters: Parameters
  var prevTime: Double
  
  var gBufferRenderPass: GBufferRenderPass
  var lightingRenderPass: LightingRenderPass
  
  var bloom: Bloom
  
  init(metalView: MTKView, world: GraphicsWorld, settings: Settings) {
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
    
    // uniforms and parameters
    self.uniforms = Uniforms()
    self.parameters = Parameters()
    
    // world
    self.world = world
    
    // timer
    self.prevTime = CFAbsoluteTimeGetCurrent()
    
    // bloom
    self.bloom = Bloom(device: self.device)
    
    // settings
    self.settings = settings
    
    // render passes
    self.gBufferRenderPass = GBufferRenderPass(
      metalView: metalView,
      renderPassDescriptorFromView: false
    )
    self.lightingRenderPass = LightingRenderPass(
      metalView: metalView,
      renderPassDescriptorFromView: true
    )
    
    // ------------------------------------
    // ------------------------------------
    
    // must be called after all variables have been initialised
    super.init()
    
    // configure world and lighting
    self.configureMeshes()
    self.world.lighting.configureLights(device: self.device)
    self.world.renderer = self
    
    // late-initialise render passes
    self.initLateRenderPasses(metalView: metalView)
    
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
  
  func initLateRenderPasses(metalView: MTKView) {
    gBufferRenderPass.initLate(renderer: self)
    lightingRenderPass.initLate(renderer: self)
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
    self.world.update(windowSize: size)
    self.gBufferRenderPass.resize(metalView: mtkView, size: size)
    self.lightingRenderPass.resize(metalView: mtkView, size: size)
    self.bloom.resize(metalView: mtkView, size: size)
  }
  
  func draw(in metalView: MTKView) {
      
    guard
      let commandBuffer = self.commandQueue.makeCommandBuffer()
    else {
      fatalError("Command buffer could not be created.")
    }
    
    guard
      let metalViewRenderPassDescriptor = metalView.currentRenderPassDescriptor
    else {
      fatalError("Render pass descriptor could not be obtained.")
    }
    
    // update world
    let currentTime = CFAbsoluteTimeGetCurrent()
    let deltaTime = Float(currentTime - self.prevTime)
    self.prevTime = currentTime
    self.world.update(deltaTime: deltaTime)
    // -----------
    
    self.updateUniformsAndParameters(world: self.world)
    
    drawRenderPasses(
      commandBuffer: commandBuffer,
      metalViewRenderPassDescriptor: metalViewRenderPassDescriptor,
        // any render pass that is drawn to the screen MUST be sent the metalView renderPassDescriptor
      world: world,
      uniforms: uniforms,
      parameters: parameters
    )
    
    guard let drawable = metalView.currentDrawable else {
      print("Renderer.swift: drawable not obtained.")
      return
    }

    commandBuffer.present(drawable)
    commandBuffer.commit()
      
  }
  
  func drawRenderPasses(
    commandBuffer: MTLCommandBuffer,
    metalViewRenderPassDescriptor: MTLRenderPassDescriptor,
    world: GraphicsWorld,
    uniforms: Uniforms,
    parameters: Parameters
  ) {
    // set G-buffer render pass
//    self.gBufferRenderPass?.renderPassDescriptor = renderPassDescriptor
    self.gBufferRenderPass.draw(
      commandBuffer: commandBuffer,
      metalViewRenderPassDescriptor: nil,
      world: self.world,
      uniforms: self.uniforms,
      parameters: self.parameters
    )
    
    // ! TODO: THESE SHOULD NOT BE CALLED EVERY FRAME!!! Furthermore, the reconfiguration of lights should only reconfigure those lights that have been affected
    self.world.lighting.configureLights(device: self.device)
    
    // set lighting render pass
    self.lightingRenderPass.albedoTexture = gBufferRenderPass.albedoTexture
    self.lightingRenderPass.normalTexture = gBufferRenderPass.normalTexture
    self.lightingRenderPass.positionTexture = gBufferRenderPass.positionTexture
    self.lightingRenderPass.bloomTexture = gBufferRenderPass.bloomTexture
    self.lightingRenderPass.draw(
      commandBuffer: commandBuffer,
      metalViewRenderPassDescriptor: metalViewRenderPassDescriptor,
      world: world,
      uniforms: uniforms,
      parameters: parameters
    )
    
//    self.bloom.postProcess(
//      inputTexture: metalView.currentDrawable!.texture,
//      commandBuffer: commandBuffer
//    )
  }
  
  func updateUniformsAndParameters(world: GraphicsWorld) {
    self.uniforms.viewMatrix = self.world.mainCamera.viewMatrix
    self.uniforms.projectionMatrix = self.world.mainCamera.projectionMatrix
      // NOTE: model matrices are updated where you'd expect: in the individual model renderer
    
    self.parameters.lightCount = UInt32(self.world.lighting.lights.count)
    self.parameters.cameraPosition = self.world.mainCamera.position
      // Q: querying lightCount each time is inefficient?
  }
}
