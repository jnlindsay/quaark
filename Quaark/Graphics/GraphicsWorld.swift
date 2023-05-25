//
//  GraphicsWorld.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

import SwiftUI
import MetalKit

class GraphicsWorld : NSEventListener {
  
  @ObservedObject var settings: Settings
  var mainCamera: ArcballCamera
  var models: [GraphicsModel]
  var lighting: GraphicsLighting
  var keyboardModels: [KeyboardModel]
  weak var renderer: Renderer?

  // ! TODO: initialise renderer immediately?
  init(settings: Settings) {
    self.settings = settings
    
    self.mainCamera = ArcballCamera()
    self.mainCamera.transform.position = [0.0, 0.0, -3.0]
    
    let monkeyModel = GraphicsModel(name: "monkey-left-handed.obj")
    monkeyModel.transforms.append(Transform(position: [-1, -1, 0]))
    monkeyModel.transforms.append(Transform(position: [1, 1, 0]))
    self.models = [monkeyModel]
  
    
    self.lighting = GraphicsLighting(settings: settings)
    
    self.keyboardModels = []
      
    let position1 = simd_float3(-1, 1, -1)
    let colour1   = simd_float4(1, 0, 0, 1)
    self.lighting.addPointLight(position: position1, colour: colour1.xyz)
    self.addSphere(position: position1, colour: colour1)
  
    let position2 = simd_float3(1, -1, -1)
    let colour2   = simd_float4(0, 0, 1, 1)
    self.lighting.addPointLight(position: position2, colour: colour2.xyz)
    self.addSphere(position: position2, colour: colour2)
  }
  
  func update(deltaTime: Float) {   
    self.mainCamera.update(deltaTime: deltaTime)
    self.lighting.pointLights[0].attenuation.x = settings.lightIntensity1
    self.lighting.pointLights[0].attenuation.y = settings.lightIntensity2
    self.lighting.pointLights[0].attenuation.z = settings.lightIntensity3
    self.lighting.pointLights[1].attenuation.x = settings.lightIntensity1
    self.lighting.pointLights[1].attenuation.y = settings.lightIntensity2
    self.lighting.pointLights[1].attenuation.z = settings.lightIntensity3
    for model in self.models {
      model.transforms[0].rotation.y -= 0.01
      model.transforms[1].rotation.y += 0.04
      model.transforms[2].rotation.y += 0.02
    }
  }
  
  func update(windowSize: CGSize) {
    self.mainCamera.update(windowSize: windowSize)
  }
  
  func addKeyboardModel(keyboardModel: KeyboardModel) {
    self.keyboardModels.append(keyboardModel)
  }
  
  func handleNSEvent(event: NSEvent, broadcaster: MTKViewWithNSEventBroadcaster) {
    self.mainCamera.handleNSEvent(event: event, broadcaster: broadcaster)
  }
  
  func reconfigureMeshes() {
    // TODO: MOVE TO METAL VIEW
    if let renderer = self.renderer {
      renderer.configureMeshes()
    }
  }
  
  func addSphere(position: simd_float3, colour: simd_float4) {
    // ! WARNING: inefficient. The array should be a fixed size n, and n should be sent to the vertex (?) buffer. Difficulty: the shader must somehow know when to ignore `nil` models if models are optional. USE GPU INSTANCING?
    
    let newSphere = GraphicsModel(name: "sphere.obj")
    newSphere.transforms[0].position = position
    newSphere.transforms[0].scale = 0.2
    newSphere.colour = colour
    
//    self.models.append(newSphere)
  }

}

extension GraphicsWorld : KeyboardListener {
  func handleKeyboardEvent(keyboardModel: KeyboardModel) {
    
    if (!keyboardModel.allNotesOff) {
      let newPosition = simd_float3(
        Float.random(in: -5 ... 5),
        Float.random(in: -5 ... 5),
        Float.random(in: -5 ... 5)
      )
      let newColour = simd_float4(
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        1
      )

//      self.lighting.addPointLight(position: newPosition, colour: newColour.xyz)
      self.addSphere(position: newPosition, colour: newColour)
      self.reconfigureMeshes()
    }
  }
}

enum ModelType {
  case imported, sphere
}
