//
//  ChordModel.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 11/3/2023.
//

import Foundation

private let NUM_NOTES = 128

public class KeyboardModel : ObservableObject {
    
  @Published private var notesOnOff: [Bool]
  @Published private var chord: Chord?
  @Published private var dissonance: Float?
  private var listeners: [KeyboardListener]
  
  public var allNotesOff: Bool
  
  init() {
    self.notesOnOff = [Bool](repeating: false, count: NUM_NOTES)
    self.listeners = []
    self.allNotesOff = true
  }
  
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

  func updateKeyboardState(_ note: Note) {
    /*
     ! WARNING: BAD CODE (highly inefficient looping
                          through keyboard multiple times)
     
     TODO: parallelise so that keyboard is looped through only ONCE
     */
    
    updateNotesOnOffAndChord(note)
    updateChord()
    updateDissonance()
    updateAllNotesOff()
    broadcastEvent(note)
  }

  private func updateNotesOnOffAndChord(_ note: Note) {
    /*
        Note: as of Feb 5, 2023, there must be a "single source of truth" for notes on,
              which is currently the `notesOnOff` boolean array. Each MIDI update loop, this
              array must be the FIRST data structure to be updated, so that others might
              read from it afterwards.
     */
    
//    if (note.status == 0x90 || note.status == 0x80) {
//      // 0x90 is on, 0x80 is off
//      self.notesOnOff[Int(note.note) - 1] = (note.status == 0x90)
//    }
//
//    if (note.velocity == 0x00) {
//      self.notesOnOff[Int(note.note) - 1] = false
//    }
    
    if (note.onStatus) {
      self.notesOnOff[Int(note.note) - 1] = true
    } else if (note.offStatus) {
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
  
  private func updateAllNotesOff() {
    self.allNotesOff = true
    for note in notesOnOff {
      if (note) {
        self.allNotesOff = false
        return
      }
    }
  }
  
  func addListener(listener: KeyboardListener) {
    self.listeners.append(listener)
  }
  
  private func broadcastEvent(_ note: Note) {
    if (note.onStatus) {
      for listener in listeners {
        listener.handleKeyboardEvent(keyboardModel: self)
      }
    }
  }
    
}

protocol KeyboardListener {
  func handleKeyboardEvent(keyboardModel: KeyboardModel)
}
