//
//  Lighting.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float3 phongLighting(
  float3 normal,
  float3 position,
  constant Parameters &parameters,
  constant Light *lights,
  float3 baseColour
);

#endif /* Lighting_h */
