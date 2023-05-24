//
//  Chord_AnalyserApp.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import Foundation

@main
struct Quaark : App {
    
  private var midiConnection: CoreMIDIConnection
  private var metalView: MetalView
  private var world: GraphicsWorld
  private var settings: Settings
  
  init() {
    print("Chord Analyser has started.")
    
    self.settings = Settings()
    
    self.world = GraphicsWorld(settings: self.settings)
    self.metalView = MetalView(world: self.world, settings: self.settings)
    self.midiConnection = CoreMIDIConnection()
    
    self.midiConnection.startMIDIListener()
    self.midiConnection.getKeyboardModel().addListener(listener: world)
  }
    
  var body: some Scene {
    WindowGroup {
      KeyboardView(
        keyboardModel: self.midiConnection.getKeyboardModel(),
        midiConnection: midiConnection,
        world: self.world,
        settings: self.settings
      )
    }
    Window("MetalView", id: "metalView") {
      self.metalView
    }
  }
  
}
