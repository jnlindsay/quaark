//
//  Population.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import MetalKit

struct Population {
  var quads: [Quad] = []
  var numObjects: Int = 0
  
  init(numObjects: Int, device: MTLDevice, scale: Float = 1) {
    for _ in 0..<numObjects {
      let centre = simd_float2(Float.random(in: -1.0...1.0), Float.random(in: -1.0...1.0))
      quads.append(Quad(device: device, scale: scale, centre: centre))
    }
    self.numObjects = numObjects
  }
}
