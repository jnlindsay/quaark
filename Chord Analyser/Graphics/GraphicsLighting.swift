//
//  GraphicsLighting.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

struct GraphicsLighting {
  var lights: [Light]
  
  let sunLight: Light = {
    var light = Self.buildDefaultLight()
    light.position = [1, 2, -2]
    return light
  }()
  
  let ambientLight: Light = {
    var light = Self.buildDefaultLight()
    light.colour = [0.05, 0.1, 0]
    light.type = AmbientLight
    return light
  }()
  
  init() {
    self.lights = []
    self.lights.append(self.sunLight)
    self.lights.append(self.ambientLight)
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
