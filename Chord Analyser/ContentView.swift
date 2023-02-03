//
//  ContentView.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var midiConnection = CoreMIDIConnection()
    
    var body: some View {
        ZStack {
            midiConnection.backgroundColour
            VStack {
                Spacer()
                HStack {
                    Text("Packet note:")
                }
                HStack {
                    Text("Notes on:")
                    Text(String(describing: midiConnection.keysOnNames))
                }
                HStack {
                    Text("Previous chords:")
                    Text(String(describing: midiConnection.prevNotes))
                }
                Spacer()
                Text(String(midiConnection.chordName))
                    .font(.largeTitle)
                Spacer()
                PhantomKeyboardView(
                    midiConnection: midiConnection
                )
                Spacer()
            }
        }
//            .background(midiConnection.backgroundColour)
    }
}

// Phantom keyboard. The word "phantom" indicates the
//   "missing" black keys on the keyboard are drawn but have
//   a "clear" colour.
struct PhantomKeyboardView : View {
    
    private let keyOnColour = Color.teal
    @ObservedObject var midiConnection: CoreMIDIConnection
    
    // 52 white keys
    private let whiteKeyToNote: [Int32] = [ // Note: the index of 59, for example, gives MIDI note 60 (middle C)
        20, 22,                             // 0th octave
        23, 25, 27,     28,  30,  32,  34,  // 1st
        35, 37, 39,     40,  42,  44,  46,  // 2nd
        47, 49, 51,     52,  54,  56,  58,  // 3rd
        59, 61, 63,     64,  66,  68,  70,  // 4th
        71, 73, 75,     76,  78,  80,  82,  // 5th
        83, 85, 87,     88,  90,  92,  94,  // 6th
        95, 97, 99,    100, 102, 104, 106,  // 7th
        107
    ]
    
    // given a note that may be phantom or black, the MIDI note is returned
    private let blackKeyToNote: [Int: Int32] = [
        // 15 phantom keys at the following positions:
        //     1, 4, 8, 11, 15, 18, 22, 25, 29, 32, 36, 39, 43, 46, 50
        
        // 36 black keys
         0: 21,                                        // 0th octave
         2: 24,  3: 26,     5:  29,  6:  31,  7:  33,  // 1st
         9: 36, 10: 38,    12:  41, 13:  43, 14:  45,  // 2nd
        16: 48, 17: 50,    19:  53, 20:  55, 21:  57,  // 3rd
        23: 60, 24: 62,    26:  65, 27:  67, 28:  69,  // 4th
        30: 72, 31: 74,    33:  77, 34:  79, 35:  81,  // 5th
        37: 84, 38: 86,    40:  89, 41:  91, 42:  93,  // 6th
        44: 96, 45: 98,    47: 101, 48: 103, 49: 105   // 7th
    ]
    
    func phantomOrBlackKeyToColour(i: Int) -> Color {
        let maybeNote: Int32? = blackKeyToNote[i]
        if let note = maybeNote {
            return midiConnection.midiAdapter.getNote(note) ? keyOnColour : .black
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack {
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
                        .fill(midiConnection.midiAdapter.getNote(whiteKeyToNote[$0]) ? keyOnColour : .white)
                        .frame(width: 10, height: 100)
                        // -281 = -(572 / 2) + 5
                        .offset(x: -280.5 + CGFloat($0) * 11)
                }
                
                // Black keys (including phantom keys)
                ForEach(0..<51) {
                    Rectangle()
                        .fill(phantomOrBlackKeyToColour(i: $0))
                        .frame(width: 7, height: 60)
                        .offset(x: -280.5 + 5.5 + CGFloat($0) * 11, y: -20)
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
