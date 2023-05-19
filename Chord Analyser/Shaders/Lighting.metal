//
//  Lighting.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

float3 phongLighting(
  float3 normal,
  float3 position,
  constant Parameters &parameters,
  constant Light *lights,
  float3 baseColour
) {
  float3 diffuseColour = 0;
  float3 ambientColour = 0;
  float3 specularColour = 0;
  for (uint i = 0; i < parameters.lightCount; i++) {
    Light light = lights[i];
    switch (light.type) {
      case SunLight: {
        float3 lightDirection = normalize(-light.position);
        float diffuseIntensity =
          saturate(-dot(lightDirection, normal));
        diffuseColour +=
            light.colour
          * baseColour
          * diffuseIntensity;
        break;
      }
      case PointLight: {
        break;
      }
      case SpotLight: {
        break;
      }
      case AmbientLight: {
        ambientColour += light.colour;
        break;
      }
      case UnusedLight: {
        break;
      }
    }
  }
  return diffuseColour + specularColour + ambientColour;
}
