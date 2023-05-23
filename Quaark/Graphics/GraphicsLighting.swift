//
//  GraphicsLighting.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

import MetalKit

struct GraphicsLighting {
  var lights: [Light]
  var sunLights: [Light]
  var pointLights: [Light]
  
  var lightsBuffer: MTLBuffer?
  var sunLightsBuffer: MTLBuffer?
  var pointLightsBuffer: MTLBuffer?
  
  private var lightIndex: Int
  private let maxLights: Int // ! TODO: be careful about default lights; they might get overwritten
  
  weak var device: MTLDevice?
  
  init() {
    self.sunLights = [self.sunLight, self.ambientLight]
    self.lights = self.sunLights
    self.pointLights = []
    self.lights += self.pointLights
    
    self.lightIndex = 0
    self.maxLights = 10
  }
  
  mutating func initAfterDeviceSet(device: MTLDevice) {
    // NOTE: this should be called by the Renderer init()
    
    self.sunLightsBuffer = Self.createBuffer(
      device: device,
      lights: self.sunLights
    )
    self.pointLightsBuffer = Self.createBuffer(
      device: device,
      lights: self.pointLights
    )
    self.lightsBuffer = Self.createBuffer(
      device: device,
      lights: self.lights
    )
  }
  
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
      light.attenuation = [2, 0, 0]
    return light
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
  
  static func createBuffer(
    device: MTLDevice,
    lights: [Light]
  ) -> MTLBuffer {
    var lights = lights
    return device.makeBuffer(
      bytes: &lights,
      length: MemoryLayout<Light>.stride * lights.count,
      options: []
    )!
  }
  
  mutating func addPointLight(position: simd_float3, colour: simd_float3) {
    // ! WARNING: inefficient. The array should be a fixed size n, and n should be sent to the lighting buffer. Difficulty: the lighting shader must somehow know when to ignore `nil` lights if lights are optional.
    
    let newLight = self.pointLight(position, colour)
    
    // ! TODO: DODGIEST CODE EVER: new point lights are appended to BOTH the `pointLights` as well as the `lights` arrays
    
    if self.pointLights.count < self.maxLights {
      self.lights.append(newLight)
      self.pointLights.append(newLight)
    } else {
      if self.lightIndex >= self.maxLights {
        self.lightIndex = 0
      }
      self.pointLights[lightIndex] = newLight
      self.lights[lightIndex] = newLight
      self.lightIndex += 1
    }
  }
}
