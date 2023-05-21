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
  let lighting: GraphicsLighting
  weak var renderer: Renderer?
  
  init() {
    self.mainCamera = ArcballCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]

    let monkeyModel = GraphicsModel(name: "monkey-left-handed.obj")
    self.models = [monkeyModel]

    self.keyboardModels = []
    self.lighting = GraphicsLighting()
  }
  
  func update(deltaTime: Float) {
    self.mainCamera.update(deltaTime: deltaTime)
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
    
    for model in models {
      if (!keyboardModel.allNotesOff) {
        model.setColour(colour: simd_float4(
          Float.random(in: 0.0 ... 1.0),
          Float.random(in: 0.0 ... 1.0),
          Float.random(in: 0.0 ... 1.0),
          1.0
        ))
      }
    }
    
  }
}
