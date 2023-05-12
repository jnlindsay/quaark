//
//  World.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

struct World {
  public var populations: [Population] = []
  
  mutating func populatePrimitive(numObjects: Int, device: MTLDevice, scale: Float) {
    let population = Population(numObjects: numObjects, device: device, scale: scale)
    self.populations.append(population)
  }
}
