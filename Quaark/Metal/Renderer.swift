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
  
  // ! TODO: FIND A WAY TO MAKE RENDER PASSES MANDATORY
  var forwardRenderPass: ForwardRenderPass?
  var gBufferRenderPass: GBufferRenderPass?
  var lightingRenderPass: LightingRenderPass?
  
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
    
    // must be called after all variables have been initialised
    super.init()
    
    // render passes
    self.forwardRenderPass = ForwardRenderPass(
      renderer: self,
      metalView: metalView
    )
    self.gBufferRenderPass = GBufferRenderPass(
      renderer: self,
      metalView: metalView
    )
    self.lightingRenderPass = LightingRenderPass(
      renderer: self,
      metalView: metalView
    )
    
    // configure world and lighting
    self.configureMeshes()
    self.world.lighting.configureLights(device: self.device)
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
    self.forwardRenderPass?.resize(metalView: mtkView, size: size)
    self.gBufferRenderPass?.resize(metalView: mtkView, size: size)
    self.lightingRenderPass?.resize(metalView: mtkView, size: size)
    self.bloom.resize(view: mtkView, size: size)
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
    
    // update world
    let currentTime = CFAbsoluteTimeGetCurrent()
    let deltaTime = Float(currentTime - self.prevTime)
    self.prevTime = currentTime
    self.world.update(deltaTime: deltaTime)
    
    // update uniforms and parameters
    self.updateUniformsAndParameters(world: self.world)
    
    if (true) {
      // set G-buffer render pass
      self.gBufferRenderPass?.draw(
        commandBuffer: commandBuffer,
        world: self.world,
        uniforms: self.uniforms,
        parameters: self.parameters
      )
      
      // ! TODO: THESE SHOULD NOT BE CALLED EVERY FRAME!!!
      // furthermore, the reconfiguration of lights should only reconfigure those lights that have been affected
      self.world.lighting.configureLights(device: self.device)
      for model in self.world.models {
        model.configureMeshes(device: self.device)
      }
      
      // set lighting render pass
      self.lightingRenderPass?.albedoTexture = gBufferRenderPass?.albedoTexture
      self.lightingRenderPass?.normalTexture = gBufferRenderPass?.normalTexture
      self.lightingRenderPass?.positionTexture = gBufferRenderPass?.positionTexture
      self.lightingRenderPass?.renderPassDescriptor = renderPassDescriptor
      self.lightingRenderPass?.draw(
        commandBuffer: commandBuffer,
        world: world,
        uniforms: uniforms,
        parameters: parameters
      )
    } else {
      // set forward render pass
      self.forwardRenderPass?.renderPassDescriptor = renderPassDescriptor
      self.forwardRenderPass?.draw(
        commandBuffer: commandBuffer,
        world: self.world,
        uniforms: self.uniforms,
        parameters: self.parameters
      )
    }
    
    // bloom effect
//    self.bloom.postProcess(view: metalView, commandBuffer: commandBuffer)
    
    guard let drawable = metalView.currentDrawable else {
      print("Renderer.swift: drawable not obtained.")
      return
    }

    commandBuffer.present(drawable)
    commandBuffer.commit()
      
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

protocol Renderable {
  func render(
    commandEncoder: MTLRenderCommandEncoder,
    uniforms: Uniforms,
    parameters: Parameters
  )
}
