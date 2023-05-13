//
//  GraphicsModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

struct GraphicsModel {
  let name: String
//  let assetURL: URL
  let meshes: [GraphicsMesh]
  
  init(name: String) {
    self.name = name
    
//    guard let newAssetURL = Bundle.main.url(
//      forResource: name,
//      withExtension: nil
//    ) else {
//      fatalError("Model \(name) not found.")
//    }
//    self.assetURL = newAssetURL
    
    self.meshes = []
  }
  
  func createMeshes(device: MTLDevice) {
    print("Meshes created!")
  }
  
}
