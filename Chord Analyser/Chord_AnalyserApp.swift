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
  private var midiEventHandler: MIDIEventHandler
  private var metalView: MetalView
  private var world: GraphicsWorld
  
  var body: some Scene {
    WindowGroup {
      KeyboardView(
         keyboardModel: self.midiConnection.getKeyboardModel()
      )
    }
    Window("MetalView", id: "metalView") {
      self.metalView
    }
  }
  
  init() {
    print("Chord Analyser has started.")
    
    self.midiEventHandler = MIDIEventHandler()
    self.world = GraphicsWorld()
    self.metalView = MetalView(world: self.world)
    self.midiEventHandler.addListener(midiListener: self.world)
    self.midiConnection = CoreMIDIConnection(midiEventHandler: self.midiEventHandler) // TODO: listener wrong way around
    self.midiConnection.startMIDIListener()
  }
    
}
