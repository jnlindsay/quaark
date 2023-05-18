//
//  Camera.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

import CoreGraphics

protocol Camera : Transformable {
  var transform: Transform { get set }
  
  var projectionFOV: Float        { get set }
  var nearPlane:     Float        { get set }
  var farPlane:      Float        { get set }
  var aspectRatio:   Float        { get set }
  
  var projectionMatrix: simd_float4x4 { get }
  var viewMatrix:       simd_float4x4 { get }
  
  mutating func update(windowSize: CGSize)
  mutating func update(deltaTime: Float)
}

extension Camera {
  var projectionMatrix: simd_float4x4 {
    return createProjectionMatrix(
      projectionFOV: self.projectionFOV,
      nearPlane:     self.nearPlane,
      farPlane:      self.farPlane,
      aspectRatio:   self.aspectRatio)
  }
  
  var viewMatrix: simd_float4x4 {
    let rotationMatrix = createRotationMatrix(
      angleX: self.rotation.x,
      angleY: self.rotation.y,
      angleZ: self.rotation.z
    )
    
    let translationMatrix = createTranslationMatrix(
      x: self.position.x,
      y: self.position.y,
      z: self.position.z
    )
    
    return (translationMatrix * rotationMatrix).inverse
  }
}

struct MainCamera : Camera {
  
  var transform: Transform
  
  var projectionFOV: Float
  var nearPlane:     Float
  var farPlane:      Float
  var aspectRatio:   Float
  
  init() {
    self.transform = Transform()
    
    self.projectionFOV = Float(70).degreesToRadians
    self.nearPlane = 0.1
    self.farPlane = 100
    self.aspectRatio = 1.0
  }
  
  mutating func update(windowSize: CGSize) {
    self.aspectRatio = Float(windowSize.width / windowSize.height)
  }
  
  mutating func update(deltaTime: Float) { }
  
}
