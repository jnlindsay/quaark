//
//  Pitch.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 15/12/2022.
//

import Foundation

// In MIDI 1.0, each note is assigned a numeric value, where middle C is 60.
//   Here, we call each numeric value in the range 0, ..., 128 a "note".
// There are 12 pitch classes.
//   0  <-> C
//   1  <-> C# ~ Db
//   2  <-> D
//   ...
//   11 <-> B

enum PitchClass : Int {
    case defaultPitchClass
    case c
    case csh
    case d
    case dsh
    case e
    case f
    case fsh
    case g
    case gsh
    case a
    case ash
    case b
    
    var name: String {
        switch self {
        case .c:   return "C"
        case .csh: return "D♭"
        case .d:   return "D"
        case .dsh: return "E♭"
        case .e:   return "E"
        case .f:   return "F"
        case .fsh: return "F#"
        case .g:   return "G"
        case .gsh: return "A♭"
        case .a:   return "A"
        case .ash: return "B♭"
        case .b:   return "B"
        default:   return "N/A"
        }
    }
}

extension PitchClass : Comparable {
    static func < (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    static func == (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

func toPClass(_ note: UInt8) -> PitchClass {
    switch note % 12 {
    case 0:  return .c
    case 1:  return .csh
    case 2:  return .d
    case 3:  return .dsh
    case 4:  return .e
    case 5:  return .f
    case 6:  return .fsh
    case 7:  return .g
    case 8:  return .gsh
    case 9:  return .a
    case 10: return .ash
    case 11: return .b
    default: return .defaultPitchClass
    }
}

enum Interval {
    case unison
    case minSecond
    case majSecond
    case minThird
    case majThird
    case perfFourth
    case dimFifth
    case perfFifth
    case minSixth
    case majSixth
    case minSeventh
    case majSeventh
    case octave
    case defaultInterval
}

func toInterval(_ note1: UInt8, _ note2: UInt8) -> Interval {
    switch abs(Int(note1) - Int(note2)) % 12 {
    case 0:  return Interval.unison
    case 1:  return Interval.minSecond
    case 2:  return Interval.majSecond
    case 3:  return Interval.minThird
    case 4:  return Interval.majThird
    case 5:  return Interval.perfFourth
    case 6:  return Interval.dimFifth
    case 7:  return Interval.perfFifth
    case 8:  return Interval.minSixth
    case 9:  return Interval.majSixth
    case 10: return Interval.minSeventh
    case 11: return Interval.majSeventh
    case 12: return Interval.octave
    default: return Interval.defaultInterval
    }
}

func toInterval(_ pClass1: PitchClass, _ pClass2: PitchClass) -> Interval {
    switch abs(pClass1.rawValue - pClass2.rawValue) % 12 {
    case 0:  return Interval.unison
    case 1:  return Interval.minSecond
    case 2:  return Interval.majSecond
    case 3:  return Interval.minThird
    case 4:  return Interval.majThird
    case 5:  return Interval.perfFourth
    case 6:  return Interval.dimFifth
    case 7:  return Interval.perfFifth
    case 8:  return Interval.minSixth
    case 9:  return Interval.majSixth
    case 10: return Interval.minSeventh
    case 11: return Interval.majSeventh
    case 12: return Interval.octave
    default: return Interval.defaultInterval
    }
}

struct Note {
    var velocity: UInt8
    var note:     UInt8
    var channel:  UInt8
    var status:   UInt8
  
  var onStatus: Bool {
    // NOTE: value `false` does not imply noteOff
    
    if (self.status == 0x90) {
      return true
    }
    return false
  }
  
  var offStatus: Bool {
    // NOTE: value `false` does not imply noteOn
    
    if (self.status == 0x80 || self.velocity == 0x00) {
      return true
    }
    return false
  }
}

//          10000001 01001101 00000000
// 00000000 sssscccc nnnnnnnn vvvvvvvv
// s: status, c: channel, n: note, v: velocity

func toNote(_ midiWord: UInt32) -> Note {
    let velocity: UInt8 = UInt8(midiWord       & 0xFF)
    let note:     UInt8 = UInt8(midiWord >> 8  & 0xFF)
    let channel:  UInt8 = UInt8(midiWord >> 16 & 0x0F)
    let status:   UInt8 = UInt8(midiWord >> 16 & 0xF0)
    return Note(velocity: velocity, note: note, channel: channel, status: status)
}
