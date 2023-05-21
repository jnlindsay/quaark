//
//  Camera.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

import CoreGraphics
import MetalKit

protocol Camera : Transformable, DeltaTransformable {
  var projectionFOV: Float        { get set }
  var nearPlane:     Float        { get set }
  var farPlane:      Float        { get set }
  var aspectRatio:   Float        { get set }

  var projectionMatrix: simd_float4x4 { get }
  var viewMatrix:       simd_float4x4 { get }

  mutating func update(windowSize: CGSize)
  mutating func update(deltaTime: Float)
}

enum Settings {
  static var rotationSpeed: Float { 2.0 }
  static var translationSpeed: Float { 3.0 }
  static var mouseScrollSensitivity: Float { 0.005 }
}

struct ArcballCamera : Camera {
  var transform: Transform
  var deltaTransform: Transform
  
  var projectionFOV: Float
  var nearPlane:     Float
  var farPlane:      Float
  var aspectRatio:   Float
  
  let minDistance: Float
  let maxDistance: Float
  var target: simd_float3
  var distance: Float
  var rotating: Bool
  
  var projectionMatrix: simd_float4x4 {
    return createProjectionMatrix(
      projectionFOV: self.projectionFOV,
      nearPlane:     self.nearPlane,
      farPlane:      self.farPlane,
      aspectRatio:   self.aspectRatio)
  }
  
  var viewMatrix: simd_float4x4 {
    return createLookAtMatrix(
      eye: self.position,
      center: self.target,
      up: [0, 1, 0]
    )
  }
  
  init() {
    self.transform = Transform()
    self.deltaTransform = Transform()

    self.projectionFOV = Float(70).degreesToRadians
    self.nearPlane = 0.1
    self.farPlane = 100
    self.aspectRatio = 1.0
    
    self.minDistance = 0.0
    self.maxDistance = 50
    self.target = simd_float3(0, 0, 0)
    self.distance = 3
    self.rotating = false
  }
  
  mutating func update(windowSize: CGSize) {
    self.aspectRatio = Float(windowSize.width / windowSize.height)
  }
  
  mutating func update(deltaTime: Float) {
    if self.rotating {
      self.transform.rotation += self.deltaTransform.rotation * deltaTime
      self.transform.rotation.x = max(
        -.pi / 2,
         min(self.transform.rotation.x, .pi / 2)
      )
    }

    // NOTE: crucial that this is YXZ and not XYZ
    let rotationMatrix = createYXZRotationMatrix(
      angleX: -self.rotation.x,
      angleY: -self.rotation.y,
      angleZ: 0
    )
    let distanceVector = simd_float4(0, 0, -self.distance, 0)
    let rotatedVector = rotationMatrix * distanceVector
    self.transform.position =
      self.target +
      simd_float3(
        rotatedVector.x,
        rotatedVector.y,
        rotatedVector.z
      )
  }
  
  mutating func handleNSEvent(
    event: NSEvent,
    broadcaster: MTKViewWithNSEventBroadcaster
  ) {
    /*
    ! WARNING: something not quite right with the way this is done. Surely we shouldn't have to query the broadcaster's state, since we're given the event directly, right? And yet I like the "single source of truth" way of doing things. Too lazy to think hard about it right now.
     */
    
    // rotating?
    self.rotating =
      (    broadcaster.eventsState.wKeyDown
        || broadcaster.eventsState.aKeyDown
        || broadcaster.eventsState.sKeyDown
        || broadcaster.eventsState.dKeyDown
      ) ? true : false
    
    switch event.type {
    case .scrollWheel:
      let deltaY = event.scrollingDeltaY
      
      if deltaY == 0 {
        break
      } else {
        self.distance -= Float(deltaY) * Settings.mouseScrollSensitivity
        self.distance = min(self.distance, self.maxDistance)
        self.distance = max(self.distance, self.minDistance)
      }
      
    default:
      // x rotation
      var rotationX: Float = 0
      if (broadcaster.eventsState.wKeyDown || broadcaster.eventsState.sKeyDown) {
        if (!broadcaster.eventsState.wKeyDown) { rotationX =  Settings.rotationSpeed }
        if (!broadcaster.eventsState.sKeyDown) { rotationX = -Settings.rotationSpeed }
      }
      self.deltaTransform.rotation.x = rotationX

      // y rotation
      var rotationY: Float = 0
      if (broadcaster.eventsState.aKeyDown || broadcaster.eventsState.dKeyDown) {
        if (!broadcaster.eventsState.aKeyDown) { rotationY =  Settings.rotationSpeed }
        if (!broadcaster.eventsState.dKeyDown) { rotationY = -Settings.rotationSpeed }
      }
      self.deltaTransform.rotation.y = rotationY
    }
    
  }
  
}
