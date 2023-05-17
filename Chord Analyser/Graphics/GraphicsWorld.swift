//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class GraphicsWorld {
  
  var models: [GraphicsModel]
  
  init() {
    let tempModel = GraphicsModel(name: "train.usd")
    self.models = [tempModel]
  }
  
  func update(deltaTime: Float) {
    for model in models {
      model.rotation.y = sin(deltaTime)
    }
  }

}

