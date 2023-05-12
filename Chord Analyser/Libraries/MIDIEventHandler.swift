//
//  MIDIEventHandler.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

struct MIDIEventHandler {
  
  private var metalView: MetalView
  
  init(metalView: MetalView) {
    self.metalView = metalView
  }
  
//  func setMetalView(metalView: MetalView) {
//    self.metalView = metalView
//  }
  
  // ! WARNING: very incomplete and bad function
  func propagateEvent(_ note: Note) {
    
    if (note.status == 0x90) {
//      print("wow!")
      self.metalView.viewController.world.onNoteOccured()
    }
    
  }
}
