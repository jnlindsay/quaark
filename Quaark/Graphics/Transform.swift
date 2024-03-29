//
//  Transform.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

import Foundation

struct Transform {
  
  var position: simd_float3
  var rotation: simd_float3
  var scale: Float
  
  init(
    position: simd_float3 = [0, 0, 0],
    rotation: simd_float3 = [0, 0, 0],
    scale: Float = 1
  ) {
    self.position = position
    self.rotation = rotation
    self.scale    = scale
  }
  
  var modelMatrix: simd_float4x4 {
    let scaleMatrix = createScaleMatrix(factor: self.scale)
    
    let rotationMatrix = createXYZRotationMatrix(
      angleX: self.rotation.x,
      angleY: self.rotation.y,
      angleZ: self.rotation.z
    )
    
    let translationMatrix = createTranslationMatrix(
      x: self.position.x,
      y: self.position.y,
      z: self.position.z
    )
    
    return translationMatrix * rotationMatrix * scaleMatrix
  }
  
}

protocol Transformable {
  var transform: Transform { get set }
}

extension Transformable {
  var position: simd_float3 {
    get { transform.position }
    set { transform.position = newValue }
  }
  
  var rotation: simd_float3 {
    get { transform.rotation }
    set { transform.rotation = newValue }
  }
  
  var scale: Float {
    get { transform.scale }
    set { transform.scale = newValue }
  }
}

protocol DeltaTransformable where Self : Transformable {
  var deltaTransform: Transform { get set }
}
