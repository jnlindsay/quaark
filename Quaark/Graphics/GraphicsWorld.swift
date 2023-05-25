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
    
    let sphereModel = GraphicsModel(name: "sphere.obj")
    self.models.append(sphereModel)
    
    self.lighting = GraphicsLighting(settings: settings)
    
    let position1 = simd_float3(-1, 1, -1)
    let colour1   = simd_float4(1, 0, 0, 1)
    self.lighting.addPointLight(position: position1, colour: colour1.xyz)
  
    let position2 = simd_float3(1, -1, -1)
    let colour2   = simd_float4(0, 0, 1, 1)
    self.lighting.addPointLight(position: position2, colour: colour2.xyz)
    
    self.keyboardModels = []
    
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
      let numInstances = model.transforms.count
      for i in 0..<numInstances {
        model.transforms[i].rotation.y += 0.01
      }
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

      // ! TODO: make the sure max # of models/point lights is the same
      self.lighting.addPointLight(position: newPosition, colour: newColour.xyz)
      self.models[1].addInstance(transform: Transform(
        position: newPosition
      ))
      self.reconfigureMeshes()
    }
  }
}

enum ModelType {
  case imported, sphere
}
