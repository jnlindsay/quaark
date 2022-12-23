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
//    private var appState = AppState()
    
    var body: some View {
        
        VStack {
            Spacer()
            HStack {
                Text("Status:")
                Text(midiConnection.packetStatus?.description ?? "N/A")
            }
            HStack {
                Text("Packet note:")
                Text(toPClass(midiConnection.packetNote).name)
            }
            HStack {
                Text("Notes on:")
                Text(String(describing: midiConnection.notesOn))
            }
//            HStack {
//                Text("Toggle:")
//                Text(midiConnection.noteToggle ? "EVEN" : "ODD")
//            }
//            HStack {
//                Text("Bool buffer:")
//                Text(String(describing: midiConnection.pubBoolBuffer))
//            }
//            Spacer()
//            PhantomKeyboardView(
//                eventStatus: $midiConnection.eventStatus,
//                eventNote: $midiConnection.eventNote
//            )
            Text("Hello again")
            Spacer()
        }
//        .onAppear {
//            appState.receiverManager.startLogTimer()
//        }
//        .onDisappear {
//            appState.receiverManager.stopLogTimer()
//        }
    }
    
}

// Phantom keyboard. The word "phantom" indicates the
//   "missing" black keys on the keyboard are drawn but have
//   a "clear" colour.
struct PhantomKeyboardView : View {
    
    @Binding var eventStatus: EventStatus
    @Binding var eventNote: UInt32?
    
    private let keyOnColour = Color.teal
    
    // Default phantom piano key colours.
    //   Note: because of the way the keyboard is generated,
    //         the `.white` entries here are actually redundant.
    private let phantomKeyboardColours: [Color] = [
        .white, .black, .white, .clear,                                 // 0th octave
        .white, .black, .white, .black, .white, .clear,                 // 1st
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 2nd
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 3rd
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 4th
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 5th
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 6th
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 7th
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white, .black, .white, .black, .white, .clear,                 // 8th
        .white, .black, .white, .black, .white, .black, .white, .clear, // ...
        .white                                                          // 9th
    ]
    
    // Keys turned "on" on the phantom keyboard.
    //   (Phantom notes are always on so that they have a "clear" colour.)
    @State private var phantomKeyboardKeysOn: [Bool] = [
        false, false, false, false,                             // 0th octave
        false, false, false, false, false, false,               // 1st
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 2nd
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 3rd
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 4th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 5th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 6th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 7th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 8th
        false, false, false, false, false, false, false, false, // ...
        false                                                   // 9th
    ]
    
    var body: some View {
        VStack {
            Text(String(describing: eventStatus))
            Text(String(describing: eventNote))
            ZStack {
                // Background
                Rectangle()
                    .fill(.gray)
                // Note: a keyboard has 52 white keys.
                // 571 = (52 * 10 + 1) - 1
                    .frame(width: 571, height: 100)
                
                // White keys
                ForEach(0..<52) {
                    Rectangle()
                        .fill(phantomKeyboardKeysOn[$0 * 2] ? keyOnColour : .white)
                        .frame(width: 10, height: 100)
                    // -281 = -(572 / 2) + 5
                        .offset(x: -280.5 + CGFloat($0) * 11)
                }
                
                // Black keys (including phantom keys)
                ForEach(0..<51) {
                    Rectangle()
                        .fill(phantomKeyboardKeysOn[$0 * 2 + 1] ? keyOnColour
                              : phantomKeyboardColours[$0 * 2 + 1])
                        .frame(width: 7, height: 60)
                        .offset(x: -280.5 + 5.5 + CGFloat($0) * 11,
                                y: -20)
                }
            }.onChange(of: eventStatus) { _ in
                // Update notes that are on.
                switch eventStatus {
                case .noteOn: phantomKeyboardKeysOn[
                    // ! TODO: FIX HACK: evenNote SHOULD BE UNWRAPPED PROPERLY
                    midiToPhantomKeyboardNote[Int(eventNote ?? 0) - 21]] = true
                case .noteOff: phantomKeyboardKeysOn[
                    midiToPhantomKeyboardNote[Int(eventNote ?? 0) - 21]] = false
                default: break
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
