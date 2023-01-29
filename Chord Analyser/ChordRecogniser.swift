//
//  ChordRecogniser.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 27/1/2023.
//

import Foundation
import DequeModule

enum Chord : String {
    case maj = " major"
    case min = " minor"
    case dim = " dim"
    case minSeven = "m7"
    case majSeven = "Δ7"
    case domSeven = "7"
    case none = " unidentified chord"
}

// At any one time, a maximum of 16 notes can be played simultaneously. We keep track of chords using Swift's 'set' data structure.

// Given a set of keys, return the pitch classes
func keysToPitches(_ keys: Array<UInt32>) -> Set<PitchClass> {
    var res: Set<PitchClass> = Set()
    for key in keys {
        res.insert(toPClass(key))
    }
    return res
}

// Given a set of keys, return the pitch classes
func keysToPitchNames(_ keys: Set<UInt32>) -> Set<String> {
    var res: Set<String> = Set()
    for key in keys {
        res.insert(toPClass(key).name)
    }
    return res
}

// Given a set of keys, sort the keys and return the pitch classes in order
func sortKeysToPitches(_ keys: Set<UInt32>) -> Array<PitchClass> {
    var keysArray = Array(keys)
    keysArray.sort()
    var res: Array<PitchClass> = Array(repeating: .defaultPitchClass, count: keysArray.count)
    for (i, _) in res.enumerated() {
        res[i] = toPClass(keysArray[i])
    }
        
    return res
}

// Given a set of keys, sort the keys and return the pitch names in order
func sortChordtoPitchNames(keys: Set<UInt32>) -> Array<String> {
    var keysArray = Array(keys)
    keysArray.sort()
    var res: Array<String> = Array(repeating: "", count: keysArray.count)
    for (i, _) in res.enumerated() {
        res[i] = toPClass(keysArray[i]).name
    }
        
    return res
}

// given a chord in the form of a tuple, return in readable form
func chordToName(_ chord: (PitchClass, Chord)) -> String? {
    if chord.1 == .none { return nil }
    else { return chord.0.name + chord.1.rawValue }
}

// given a set of pitches, return the chord name
func toChord(_ keys: Array<UInt32>) -> (PitchClass, Chord) {
    
    // sort pitch classes
    var pitches = Array(keysToPitches(keys))
    pitches.sort()
    
    // Create dequeue of intervals
    var intervals: Deque<Interval> = []
    for i in stride(from: 0, through: pitches.count - 2, by: 1) {
        intervals.append(toInterval(pitches[i], pitches[i + 1]))
    }
    
//    print("--- INTERVALS ---")
//    print(String(describing: intervals))
//    print("-----------------")
    
    var res: (PitchClass, Chord) = (.defaultPitchClass, .none)
    
    if pitches.count <= 4 {
        switch intervals.popFirst() {
        case .minSecond:
            switch intervals.popFirst() {
            case .majThird:
                if intervals.popFirst() == .minThird { res = (pitches[1], .majSeven) }
            default: break
            }
        case .majSecond:
            switch intervals.popFirst() {
            case .minThird:
                if intervals.popFirst() == .majThird { res = (pitches[1], .minSeven) }
            case .majThird:
                if intervals.isEmpty { res = (pitches[1], .domSeven) }
                else { switch intervals.popFirst() {
                case .minThird: res = (pitches[1], .domSeven)
                default: break
                }}
            default: break
            }
        case .minThird:
            switch intervals.popFirst() {
            case .majSecond:
                switch intervals.popFirst() {
                case .majThird: res = (pitches[2], .domSeven)
                case .minThird: res = (pitches[2], .minSeven)
                default: break
                }
            case .minThird:
                if intervals.isEmpty { res = (pitches[0], .dim) }
                else { switch intervals.popFirst() {
                case .majSecond: res = (pitches[3], .domSeven)
                default: break
                }}
            case .majThird:
                if intervals.isEmpty { res = (pitches[0], .min) }
                else { switch intervals.popFirst() {
                case .minSecond: res = (pitches[3], .majSeven)
                case .minThird: res = (pitches[0], .minSeven)
                default: break
                }}
            case .perfFourth: if intervals.isEmpty { res = (pitches[2], .maj) }
            default: break
            }
        case .majThird:
            switch intervals.popFirst() {
            case .minSecond:
                if intervals.popFirst() == .majThird { res = (pitches[2], .majSeven) }
            case .minThird:
                if intervals.isEmpty { res = (pitches[0], .maj) }
                else { switch intervals.popFirst() {
                case .majSecond: res = (pitches[3], .minSeven)
                case .minThird: res = (pitches[0], .domSeven)
                case .majThird: res = (pitches[0], .majSeven)
                default: break
                }}
            case .perfFourth: if intervals.isEmpty { res = (pitches[2], .min) }
            case .dimFifth: if intervals.isEmpty { res = (pitches[0], .domSeven) }
            default: break
            }
        case .perfFourth:
            switch intervals.popFirst() {
            case .minThird: if intervals.isEmpty { res = (pitches[1], .min) }
            case .majThird: if intervals.isEmpty { res = (pitches[1], .maj) }
            default: break
            }
        case .dimFifth:
            switch intervals.popFirst() {
            case .majSecond: if intervals.isEmpty { res = (pitches[2], .domSeven) }
            default: break
            }
        default: break
        }
    }
    
    return res
}
