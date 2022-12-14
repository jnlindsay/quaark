//
//  ContentView.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import CoreMIDIInterface

struct ContentView: View {
    
    @ObservedObject private var midiConnection = CoreMIDIConnection()
    
    var body: some View {
        
        VStack {
            Text("Hi.")
            HStack {
                Text("Status:")
                Text(String(describing: midiConnection.eventStatus))
            }
            HStack {
                Text("Note:")
                Text(String(describing: midiConnection.eventNote))
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
