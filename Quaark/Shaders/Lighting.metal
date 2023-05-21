//
//  Lighting.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

#import "Lighting.h"
#include <metal_stdlib>
using namespace metal;

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
  float materialShininess = 32;
  float3 materialSpecularColour = float3(1, 1, 1);
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
        if (diffuseIntensity > 0) {
          float3 reflection =
            reflect(lightDirection, normal);
          float3 viewDirection =
            normalize(parameters.cameraPosition);
          float specularIntensity =
            pow(saturate(dot(reflection, viewDirection)),
                materialShininess);
          specularColour +=
              light.specularColour
            * materialSpecularColour
            * specularIntensity;
        }
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
//  return diffuseColour + specularColour + ambientColour;
  return diffuseColour + ambientColour;
}
