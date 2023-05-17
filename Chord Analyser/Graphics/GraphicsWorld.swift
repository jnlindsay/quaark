//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class GraphicsWorld {
  
  var models: [GraphicsModel]
  private var keyboardModels: [KeyboardModel]
  
  init() {
    let tempModel = GraphicsModel(name: "train.usd")
    self.models = [tempModel]
    self.keyboardModels = []
  }
  
  func update(deltaTime: Float) {
    for model in models {
      model.rotation.y = sin(deltaTime)
    }
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
