//
//  GraphicsLighting.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

struct GraphicsLighting {
  var lights: [Light]
  private var lightIndex: Int
  private let maxLights: Int // ! TODO: be careful about default lights; they might get overwritten
  
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
  
  let pointLight: (simd_float3, simd_float3)
    -> Light = { position, colour in
    
    var light = Self.buildDefaultLight()
    light.type = PointLight
    light.position = position
    light.colour = colour
    light.attenuation = [0.5, 0.5, 0.5]
    return light
  }
  
  init() {
    self.lights = []
    self.lightIndex = 0
    self.maxLights = 10
    self.lights.append(self.sunLight)
    self.lights.append(self.ambientLight)

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
  
  mutating func addPointLight(position: simd_float3, colour: simd_float3) {
    // ! WARNING: inefficient. The array should be a fixed size n, and n should be sent to the lighting buffer. Difficulty: the lighting shader must somehow know when to ignore `nil` lights if lights are optional.
    
    let newLight = self.pointLight(position, colour)
    
    if self.lights.count < self.maxLights {
      self.lights.append(newLight)
    } else {
      if self.lightIndex >= self.maxLights {
        self.lightIndex = 0
      }
      self.lights[lightIndex] = newLight
      self.lightIndex += 1
    }
  }
}
