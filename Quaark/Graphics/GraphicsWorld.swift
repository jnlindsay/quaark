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
//    monkeyModel.transforms.append(Transform(position: [-1, -1, 0]))
//    monkeyModel.transforms.append(Transform(position: [1, 1, 0]))
    monkeyModel.colour = simd_float4(0.2, 0, 0.7, 1)
    self.models = [monkeyModel]
    
    let sphereModel = GraphicsModel(name: "sphere.obj")
    sphereModel.colour = simd_float4(0.5, 0.1, 0.2, 1)
    self.models.append(sphereModel)
    
    self.lighting = GraphicsLighting(settings: settings)
    
    let position1 = simd_float3(0, 0, 0)
    let colour1   = simd_float4(0, 0, 0, 1)
    self.lighting.addPointLight(position: position1, colour: colour1.xyz)
    
    self.keyboardModels = []
    
  }
  
  func update(deltaTime: Float) { 
    self.mainCamera.update(deltaTime: deltaTime)
    
    // TODO: UPDATE ALL POINT LIGHTS
    self.lighting.pointLights[0].attenuation.x = settings.lightIntensity1
    self.lighting.pointLights[0].attenuation.y = settings.lightIntensity2
    self.lighting.pointLights[0].attenuation.z = settings.lightIntensity3
    for model in self.models {
      let numInstances = model.instances.count
      let strength = settings.emissiveStrength
      for i in 0..<numInstances {
        model.instances[i].transform.rotation.y += 0.01
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
  func handleKeyboardEvent(
    keyboardModel: KeyboardModel,
    note: Note
  ) {
    
    if (!keyboardModel.allNotesOff) {
      let newPosition = simd_float3(
        Float.random(in: -1 ... 1),
        rangeNormalise(
          in: note.note,
          inMin: 0,
          inMax: 127,
          outMin: -20,
          outMax: 20
        ),
        Float.random(in: -1 ... 1)
      )
      let newColour = simd_float4(
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        Float.random(in: 0 ... 1),
        1
      )

      // ! TODO: make the sure max # of models/point lights is the same
      self.lighting.addPointLight(position: newPosition, colour: newColour.xyz)
      self.models[1].addInstance(
        transform: Transform(
          position: newPosition,
          scale: 0.4
        ),
        albedo: newColour
      )
      self.reconfigureMeshes()
    }
  }
}

enum ModelType {
  case imported, sphere
}
