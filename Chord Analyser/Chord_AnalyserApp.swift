//
//  Chord_AnalyserApp.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import Foundation

@main
struct Chord_AnalyserApp: App {
    
  private var midiConnection: CoreMIDIConnection
  private var keyboardModel: KeyboardModel
  private var metalView: MetalView
  private var midiEventHandler: MIDIEventHandler
  
  var body: some Scene {
    WindowGroup {
      KeyboardView(keyboardModel: self.keyboardModel)
    }
    Window("MetalView", id: "metalView") {
      metalView
    }
  }
  
  init() {
    print("Chord Analyser has started.")
    
    self.keyboardModel = KeyboardModel()
    self.metalView = MetalView(keyboardModel: self.keyboardModel)
    self.midiEventHandler = MIDIEventHandler(metalView: self.metalView)    
    self.midiConnection = CoreMIDIConnection(
      keyboardModel: self.keyboardModel,
      midiEventHandler: self.midiEventHandler
    )
    self.midiConnection.startMIDIListener()
  }
    
}
