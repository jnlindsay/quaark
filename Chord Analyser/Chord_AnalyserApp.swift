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
    
  private var midiConnection = CoreMIDIConnection()
  private var midiEventHandler: MIDIEventHandler
  private var keyboardModel = KeyboardModel()
  private var metalView: MetalView
  
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
    self.metalView = MetalView(
      keyboardModel: self.keyboardModel
    )
    self.midiEventHandler = MIDIEventHandler(metalView: self.metalView)
    self.midiConnection.setKeyboardModel(keyboardModel: self.keyboardModel)
    self.midiConnection.setMIDIEventHandler(midiEventHandler: self.midiEventHandler)
    self.midiConnection.startMIDIListener()
  }
    
}
