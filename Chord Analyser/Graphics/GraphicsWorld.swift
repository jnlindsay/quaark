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
  
  init() {
    self.mainCamera = MainCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]

    let monkeyModel = GraphicsModel(name: "monkey.usd")
    monkeyModel.transform.rotation = simd_float3(
      Float(90).degreesToRadians,
      Float(180).degreesToRadians,
      Float(180).degreesToRadians
    )
    self.models = [monkeyModel]
    self.keyboardModels = []
    self.lighting = GraphicsLighting()
  }
  
  func update(deltaTime: Float) {
    for model in models {
      model.transform.rotation.z = sin(deltaTime)
    }
//    self.mainCamera.rotation.y = sin(deltaTime)
  }
  
  func update(windowSize: CGSize) {
    mainCamera.update(windowSize: windowSize)
  }
  
  func addKeyboardModel(keyboardModel: KeyboardModel) {
    self.keyboardModels.append(keyboardModel)
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
