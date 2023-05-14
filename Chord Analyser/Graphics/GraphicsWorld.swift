//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class GraphicsWorld : MIDIListener {
  
  var models: [GraphicsModel]
  
  init() {
    let tempModel = GraphicsModel(name: "lowpoly-house.obj")
    self.models = [tempModel]
  }
  
  func handleMIDIEvent() {
    print("MIDI event received by class World.")
  }

}
