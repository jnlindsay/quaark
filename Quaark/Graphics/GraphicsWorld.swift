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
  private var modelIndex: Int
  private let maxModels: Int // ! TODO: be careful about default models; they might get overwritten
  
  private var keyboardModels: [KeyboardModel]
  var lighting: GraphicsLighting
  weak var renderer: Renderer?

  // ! TODO: initialise renderer immediately?
  init() {
    self.mainCamera = ArcballCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]
    self.models = []
    self.modelIndex = 1
    self.maxModels = 4
    
    let monkeyModel = GraphicsModel(name: "monkey-left-handed.obj")
    self.models.append(monkeyModel)
    
    self.keyboardModels = []
    
    self.lighting = GraphicsLighting()
    
    for _ in 1...2 {
      let newPosition = simd_float3(
        Float.random(in: -3 ... 3),
        Float.random(in: -3 ... 3),
        Float.random(in: -3 ... 3)
      )
      let newColour = simd_float4(
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        1
      )
      
      self.lighting.addPointLight(position: newPosition, colour: newColour.xyz)
      self.addSphere(position: newPosition, colour: newColour)
    }
    
  }
  
  func update(deltaTime: Float) {   
    self.mainCamera.update(deltaTime: deltaTime)
    for model in self.models {
      model.transform.rotation.y += 0.02
    }
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
  
  func addSphere(position: simd_float3, colour: simd_float4) {
    // ! WARNING: inefficient. The array should be a fixed size n, and n should be sent to the vertex (?) buffer. Difficulty: the shader must somehow know when to ignore `nil` models if models are optional.
    
    let newSphere = GraphicsModel(name: "sphere.obj")
    newSphere.transform.position = position
    newSphere.transform.scale = 0.2
    newSphere.colour = colour
      
    if self.models.count < self.maxModels {
      self.models.append(newSphere)
    } else {
      if self.modelIndex >= self.maxModels {
        self.modelIndex = 1
      }
      self.models[modelIndex] = newSphere
      self.modelIndex += 1
    }
  }

}

extension GraphicsWorld : KeyboardListener {
  func handleKeyboardEvent(keyboardModel: KeyboardModel) {
    
    if (!keyboardModel.allNotesOff) {
      let newPosition = simd_float3(
        Float.random(in: -5 ... 5),
        Float.random(in: -5 ... 5),
        Float.random(in: -5 ... 5)
      )
      let newColour = simd_float4(
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        1
      )

      self.lighting.addPointLight(position: newPosition, colour: newColour.xyz)
      self.addSphere(position: newPosition, colour: newColour)
      self.reconfigureMeshes()
    }
    
  }
}
