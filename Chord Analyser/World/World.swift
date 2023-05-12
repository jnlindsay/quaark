//
//  World.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class World {
  private var device: MTLDevice
  var populations: [Population] = []
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func populatePrimitive(numObjects: Int, device: MTLDevice, scale: Float) {
    var population = Population(numObjects: numObjects, device: device, scale: scale)
    self.populations.append(population)
  }
  
  func onNoteOccured() {
    populations[0].addObject(numObjects: 1, device: self.device, scale: 0.05)
  }
}
