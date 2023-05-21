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

func createXYZRotationMatrix(
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

func createYXZRotationMatrix(
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
  
  return rotationMatrixY * rotationMatrixX * rotationMatrixZ
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

func upperLeft(matrix: float4x4) -> simd_float3x3 {
  return simd_float3x3(rows: [
    [matrix[0][0], matrix[0][1], matrix[0][2]],
    [matrix[1][0], matrix[1][1], matrix[1][2]],
    [matrix[2][0], matrix[2][1], matrix[2][2]]
  ])
}

func createLookAtMatrix(
  eye: simd_float3,
  center: simd_float3,
  up: simd_float3
) -> simd_float4x4 {
  let z = normalize(center - eye)
  let x = normalize(cross(up, z))
  let y = cross(z, x)

  return simd_float4x4(rows: [
    [x.x, x.y, x.z, -dot(x, eye)],
    [y.x, y.y, y.z, -dot(y, eye)],
    [z.x, z.y, z.z, -dot(z, eye)],
    [  0,   0,   0,            1]
  ])
}
