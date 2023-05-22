//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class GraphicsWorld : NSEventListener {
  
  var mainCamera: ArcballCamera
  var models: [GraphicsModel]
  private var keyboardModels: [KeyboardModel]
  var lighting: GraphicsLighting
  weak var renderer: Renderer?
  
  // ! TODO: do this a better way
  var totalTime: Float = 0
  
  init() {
    self.mainCamera = ArcballCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]

    let monkeyModel = GraphicsModel(name: "monkey-left-handed.obj")
    let torusModel  = GraphicsModel(name: "torus.obj")
    torusModel.transform.scale = 1.2
    torusModel.transform.rotation.x = π / 2
//    self.models = [monkeyModel, torusModel]
    self.models = [monkeyModel]

    self.keyboardModels = []
    self.lighting = GraphicsLighting()
  }
  
  func update(deltaTime: Float) {
    self.totalTime += deltaTime
    
    self.mainCamera.update(deltaTime: deltaTime)
//    self.models[0].transform.rotation.y += 0.01

    self.lighting.lights[1].position.y = sin(self.totalTime)
    self.lighting.lights[2].position.y = sin(self.totalTime + Float.pi)
  }
  
  func update(windowSize: CGSize) {
    self.mainCamera.update(windowSize: windowSize)
  }
  
  func addKeyboardModel(keyboardModel: KeyboardModel) {
    self.keyboardModels.append(keyboardModel)
  }
  
  func handleNSEvent(event: NSEvent, broadcaster: MTKViewWithNSEventBroadcaster) {
    self.mainCamera.handleNSEvent(event: event, broadcaster: broadcaster)
  }
  
  func reconfigureMeshes() {
    // TODO: MOVE TO METAL VIEW
    if let renderer = self.renderer {
      renderer.configureMeshes()
    }
  }

}

extension GraphicsWorld : KeyboardListener {
  func handleKeyboardEvent(keyboardModel: KeyboardModel) {
    
    if (!keyboardModel.allNotesOff) {
      self.lighting.lights[1].colour = simd_float3(
        Float.random(in: 0.0 ... 1.0),
        Float.random(in: 0.0 ... 1.0),
        Float.random(in: 0.0 ... 1.0)
      )
      
      self.lighting.lights[2].colour = simd_float3(
        Float.random(in: 0.0 ... 1.0),
        Float.random(in: 0.0 ... 1.0),
        Float.random(in: 0.0 ... 1.0)
      )
    }
    
  }
}
