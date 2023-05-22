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
    light.position = [3, 4, -5]
    return light
  }()
  
  let ambientLight: Light = {
    var light = Self.buildDefaultLight()
    light.colour = [0.08, 0.08, 0.08]
    light.type = AmbientLight
    return light
  }()
  
  let redLight: Light = {
    var light = Self.buildDefaultLight()
    light.type = PointLight
    light.position = [-1, 1, -1]
    light.colour = [1, 0, 0]
    light.attenuation = [0.5, 0.5, 0.5]
    return light
  }()
  
  let blueLight: Light = {
    var light = Self.buildDefaultLight()
    light.type = PointLight
    light.position = [1, 1, -1]
    light.colour = [0, 0, 1]
    light.attenuation = [0.5, 0.5, 0.5]
    return light
  }()
  
  init() {
    self.lights = []
//    self.lights.append(self.sunLight)
    self.lights.append(self.ambientLight)
    self.lights.append(self.redLight)
    self.lights.append(self.blueLight)
  }
  
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.colour = [1, 1, 1]
    light.specularColour = [0.6, 0.6, 0.6]
    light.attenuation = [1, 0, 0]
    light.type = SunLight
    return light
  }
}
