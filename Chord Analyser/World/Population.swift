//
//  Population.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

class Population {
  var quads: [Quad] = []
  var numObjects: Int = 0
  let maxObjects: Int = 40
  
  init(numObjects: Int, device: MTLDevice, scale: Float = 1) {
    for _ in 0..<numObjects {
      let position = simd_float2(Float.random(in: -1.0...1.0), Float.random(in: -1.0...1.0))
      quads.append(Quad(device: device, scale: scale, position: position))
    }
    self.numObjects = numObjects
  }
  
  func addObject(numObjects: Int, device: MTLDevice, scale: Float = 1) {
    for _ in 0..<numObjects {
      if self.numObjects < self.maxObjects {
        let position = simd_float2(Float.random(in: -1.0...1.0), Float.random(in: -1.0...1.0))
        quads.append(Quad(device: device, scale: scale, position: position))
        self.numObjects += 1
      }
    }
  }
}
