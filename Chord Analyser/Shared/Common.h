//
//  Shared.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 15/5/2023.
//

#ifndef Shared_h
#define Shared_h

#import <simd/simd.h>

/*
 To understand the following matrices, study
 the mathematics of 3D graphics transformations.
 
 This struct is called `Uniforms` because these
 values are always constant.
 */
typedef struct {
  simd_float4x4 modelMatrix;      // object space -> world space
  simd_float4x4 viewMatrix;       //  world space -> camera space
  simd_float4x4 projectionMatrix; // camera space -> clip space
} Uniforms;

#endif /* Shared_h */
