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
    
    init() {
        print("Chord Analyser has started.")
        
        // pure shenanigans
        let myPitch = Pitch();
        myPitch.printer();
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Window("Yep", id: "yep") {
            MetalView()
        }
    }
}
