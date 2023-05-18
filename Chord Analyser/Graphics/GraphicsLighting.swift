//
//  GraphicsLighting.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

struct GraphicsLighting {
  var lights: [Light]
  
  let sunLight = {
    var light = Self.buildDefaultLight()
    light.position = [1, 2, -2]
    return light
  }()
  
  init() {
    self.lights = []
    self.lights.append(self.sunLight)
  }
  
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.colour = [1, 1, 1]
    light.specularColour = [0.6, 0.6, 0.6]
    light.attenutation = [1, 0, 0]
    light.type = SunLight
    return light
  }
  
}
