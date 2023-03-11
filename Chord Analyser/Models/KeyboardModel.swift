//
//  ChordModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/3/2023.
//

import Foundation

private let NUM_NOTES = 128

public class KeyboardModel : ObservableObject {
    
    @Published private var notesOnOff = [Bool](repeating: false, count: NUM_NOTES)
//    @Published private var chordName: String = "N/A"
    @Published private var chord: Chord?
    
    func getNotesOnOff(_ index: Int) -> Bool {
        return self.notesOnOff[index]
    }

    func updateNotesOnOffAndChord(_ note: Note) {
        /*
            Note: as of Feb 5, 2023, there must be a "single source of truth" for notes on,
                  which is currently the `notesOnOff` boolean array. Each MIDI update loop, this
                  array must be the FIRST data structure to be updated, so that others might
                  read from it afterwards.
         */
        
        if (note.status == 0x90 || note.status == 0x80) {
            // 0x90 is on, 0x80 is off
            self.notesOnOff[Int(note.note) - 1] = (note.status == 0x90)
        }
        
        if (note.velocity == 0x00) {
            self.notesOnOff[Int(note.note) - 1] = false
        }
        
        self.updateChord()
        
    }
    
    func updateChord() {
        var notes = Array<UInt8>()
        for (i, note) in self.notesOnOff.enumerated() {
            if note { notes.append(UInt8(i + 1)) }
        }
        self.chord = toChord(notes)
    }
    
    func getChordName() -> String {
        if let uChord = self.chord {
            if let uChordName = chordToName(uChord) {
                return uChordName
            } else {
                return "No chord name"
            }
        } else {
            return "No chord"
        }
    }
    
}
