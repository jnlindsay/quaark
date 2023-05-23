//
//  Lighting.metal
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/5/2023.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

float3 calculatePointLight(
  Light light,
  float3 position,
  float3 normal,
  vector_float3 baseColour
) {
  float d = distance(light.position, position);
  float3 lightDirection = normalize(light.position - position);
  float attenuation = 1.0 / (
    light.attenuation.x +
    light.attenuation.y * d +
    light.attenuation.z * d * d
  );

  float diffuseIntensity =
      saturate(dot(lightDirection, normal));
  float3 colour = light.colour * baseColour * diffuseIntensity;
  colour *= attenuation;
  return colour;
}

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
        float d = distance(light.position, position);
        float3 lightDirection = normalize(light.position - position);
        float attenuation = 1.0 / (light.attenuation.x +
                                   light.attenuation.y * d +
                                   light.attenuation.z * d * d);
        float diffuseIntensity =
          saturate(dot(lightDirection, normal));
        float3 colour = light.colour * (float3(1, 1, 1) + baseColour) * diffuseIntensity;
          // NOTE: the float3(...) added to baseColour above is to ensure there is a baseline level of glow even when the baseColour is completely black.
        colour *= attenuation;
        diffuseColour += colour;
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
