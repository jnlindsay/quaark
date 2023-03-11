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
    @ObservedObject var keyboardModel = KeyboardModel()    
    
    var body: some Scene {
        WindowGroup {
            ContentView(keyboardModel: keyboardModel)
        }
        Window("MetalView", id: "metalView") {
            MetalView()
        }
    }
    
    init() {
        print("Chord Analyser has started.")
        self.midiConnection.setKeyboardModel(keyboardModel: self.keyboardModel)
        self.midiConnection.startMIDIListener()
    }
    
}
