//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class GraphicsWorld {
  
  var mainCamera: MainCamera
  var models: [GraphicsModel]
  private var keyboardModels: [KeyboardModel]
  let lighting: GraphicsLighting
  weak var renderer: Renderer?
  
  init() {
    self.mainCamera = MainCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]

    let monkeyModel = GraphicsModel(name: "monkey-left-handed.obj")
//    let monkeyModel = GraphicsModel(url: "/Users/jeremylindsay/Documents/Xcode/monkey.obj")
//    let monkeyModel = GraphicsModel(url: "/Users/jeremylindsay/Documents/Xcode/Chord Analyser/Chord Analyser/GraphicsModels/monkey.obj")
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
  
  func handleNSEvent(event: NSEvent, type: NSEventType) {
    self.mainCamera.handleNSEvent(event: event, type: type)
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
