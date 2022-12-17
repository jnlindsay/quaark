//
//  Chord_AnalyserApp.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import Foundation
import Logger

@main
struct Chord_AnalyserApp: App {
    
    init() {
        log(.routine, "Chord Analyser has started.")            
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
