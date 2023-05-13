//
//  MIDIEventHandler.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 12/5/2023.
//

class MIDIEventHandler {
  
  //  private var metalView: MetalView
  private var midiListeners: [MIDIListener] = []
  
  init() {
  }
  
  func addListener(midiListener: MIDIListener) {
    self.midiListeners.append(midiListener)
  }
  
  // ! WARNING: very incomplete and bad function
  func propagateEvent(_ note: Note) {
    
    if (note.status == 0x90) {
//      self.metalView.viewController.world.onNoteOccured()
    }
    
    for midiListener in midiListeners {
      midiListener.handleMIDIEvent()
    }
    
  }
}

protocol MIDIListener {
  func handleMIDIEvent()
}
