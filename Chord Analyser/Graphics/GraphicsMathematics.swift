//
//  GraphicsMathematics.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 15/5/2023.
//

import simd

func createScaleMatrix(factor: Float) -> simd_float4x4 {
  return simd_float4x4(rows: [
    [factor, 0, 0, 0],
    [0, factor, 0, 0],
    [0, 0, factor, 0],
    [0, 0, 0,      1]
  ])
}

func createRotationMatrix(
  angleX: Float,
  angleY: Float,
  angleZ: Float) -> simd_float4x4 {
    
  let rotationMatrixX = simd_float4x4(rows: [
    [1, 0, 0, 0],
    [0, cos(angleX), -sin(angleX), 0],
    [0, sin(angleX),  cos(angleX), 0],
    [0, 0, 0, 1]
  ])
    
  let rotationMatrixY = simd_float4x4(rows: [
    [ cos(angleY), 0, sin(angleY), 0],
    [0, 1, 0, 0],
    [-sin(angleY), 0, cos(angleY), 0],
    [0, 0, 0, 1]
  ])
    
  let rotationMatrixZ = simd_float4x4(rows: [
    [cos(angleZ), -sin(angleZ), 0, 0],
    [sin(angleZ),  cos(angleZ), 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
  ])
  
  return rotationMatrixX * rotationMatrixY * rotationMatrixZ
}
  
func createTranslationMatrix(
  x: Float,
  y: Float,
  z: Float) -> simd_float4x4 {
    
  return simd_float4x4(rows: [
    [1, 0, 0, x],
    [0, 1, 0, y],
    [0, 0, 1, z],
    [0, 0, 0, 1]
  ])
}

func createProjectionMatrix(
  projectionFOV: Float,
  nearPlane: Float,
  farPlane: Float,
  aspectRatio: Float
) -> simd_float4x4 {
  
  let y = 1 / tan(projectionFOV * 0.5)
  let x = y / aspectRatio
  let z = farPlane / (farPlane - nearPlane)
  
  return simd_float4x4(rows: [
    [x, 0, 0, 0],
    [0, y, 0, 0],
    [0, 0, z, z * -nearPlane],
    [0, 0, 1, 0]
  ])
}

let π = Float.pi

extension Float {
  var radiansToDegrees: Float {
    (self / π) * 180
  }
  var degreesToRadians: Float {
    (self / 180) * π
  }
}
