//
//  Camera.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

import CoreGraphics
import MetalKit

protocol Camera : Transformable, DeltaTransformable, Controllable {
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
  
//  var viewMatrix: simd_float4x4 {
//    let rotationMatrix = createRotationMatrix(
//      angleX: self.rotation.x,
//      angleY: self.rotation.y,
//      angleZ: self.rotation.z
//    )
//
//    let translationMatrix = createTranslationMatrix(
//      x: self.position.x,
//      y: self.position.y,
//      z: self.position.z
//    )
//
//    return (translationMatrix * rotationMatrix).inverse
//  }
  
  var viewMatrix: simd_float4x4 {
    return createLookAtMatrix(
      eye: self.position,
      center: [0, 0, 0],
      up: [0, 1, 0]
    )
  }
  
}

struct MainCamera : Camera {
  var transform: Transform
  var deltaTransform: Transform
  var controlState: ControlState
  
  var projectionFOV: Float
  var nearPlane:     Float
  var farPlane:      Float
  var aspectRatio:   Float
  
  init() {
    self.transform = Transform()
    self.deltaTransform = Transform()
    self.controlState = ControlState()

    self.projectionFOV = Float(70).degreesToRadians
    self.nearPlane = 0.1
    self.farPlane = 100
    self.aspectRatio = 1.0
  }
  
  mutating func update(windowSize: CGSize) {
    self.aspectRatio = Float(windowSize.width / windowSize.height)
  }
  
  // ! WARNING: should updating transform be abstracted to Controllable?
  mutating func update(deltaTime: Float) {
    if self.controlState.rotating {
      self.transform.rotation += self.deltaTransform.rotation * deltaTime
    }
    
    let rotationMatrix = createRotationMatrix(
      angleX: -self.rotation.x,
      angleY: -self.rotation.y,
      angleZ: 0
    )
    let distanceVector = simd_float4(0, 0, -3, 0)
    let rotatedVector = rotationMatrix * distanceVector
    self.transform.position = simd_float3(
      rotatedVector.x,
      rotatedVector.y,
      rotatedVector.z
    )
  }
}
