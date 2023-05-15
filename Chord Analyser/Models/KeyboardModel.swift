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
    @Published private var chord: Chord?
    @Published private var dissonance: Float?
    
    // TODO: make an init() function
    
    public func getNotesOnOff(_ index: Int) -> Bool {
        return self.notesOnOff[index]
    }
    
    public func getChordName() -> String {
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
    
    public func getDissonance() -> Float {
        if let uDissonance = self.dissonance {
            return uDissonance
        }
        return -1.00
    }
    
  // TODO: this function should be abstracted out to MIDIEventHandler.swift,
  //       triggered by the high priority thread of the CoreMIDI connection.
    func updateKeyboardState(_ note: Note) {
        updateNotesOnOffAndChord(note)
        updateChord()
        updateDissonance()
    }

    private func updateNotesOnOffAndChord(_ note: Note) {
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
    }
    
    private func updateChord() {
        // TODO: modify this function to not append to an array.
        var notes = Array<UInt8>()
        for (i, note) in self.notesOnOff.enumerated() {
            if note { notes.append(UInt8(i + 1)) }
        }
        self.chord = toChord(notes)
    }
    
    private func updateDissonance() {
        // TODO: putting notes in an array is duplicated
        var notes = Array<UInt8>()
        for (i, note) in self.notesOnOff.enumerated() {
            if note { notes.append(UInt8(i + 1)) }
        }
        if notes.count == 2 {
            self.dissonance = naiveInterval(toInterval(notes[0], notes[1]))
        } else {
            self.dissonance = -1.00
        }
    }
    
}
