//
//  ChordRecogniser.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 27/1/2023.
//

import Foundation
import DequeModule

enum ChordType : String {
    case maj = " major"
    case min = " minor"
    case dim = " dim"
    case minSeven = "m7"
    case majSeven = "Δ7"
    case domSeven = "7"
    case none = " unidentified chord"
}

struct Chord {
    var root: PitchClass
    var type: ChordType
}

func keysToPitches(_ keys: Array<UInt8>) -> Set<PitchClass> {
    var res: Set<PitchClass> = Set()
    for key in keys {
        res.insert(toPClass(key))
    }
    return res
}

func keysToPitchNames(_ keys: Set<UInt8>) -> Set<String> {
    var res: Set<String> = Set()
    for key in keys {
        res.insert(toPClass(key).name)
    }
    return res
}

func sortKeysToPitches(_ keys: Set<UInt8>) -> Array<PitchClass> {
    var keysArray = Array(keys)
    keysArray.sort()
    var res: Array<PitchClass> = Array(repeating: .defaultPitchClass, count: keysArray.count)
    for (i, _) in res.enumerated() {
        res[i] = toPClass(keysArray[i])
    }
        
    return res
}

func sortChordtoPitchNames(keys: Set<UInt8>) -> Array<String> {
    var keysArray = Array(keys)
    keysArray.sort()
    var res: Array<String> = Array(repeating: "", count: keysArray.count)
    for (i, _) in res.enumerated() {
        res[i] = toPClass(keysArray[i]).name
    }
        
    return res
}

func chordToName(_ chord: Chord) -> String? {
    if chord.type == .none { return nil }
    else { return chord.root.name + chord.type.rawValue }
}

func toChord(_ keys: Array<UInt8>) -> Chord {
    
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
    
    var res: Chord?
    
    if pitches.count <= 4 {
        switch intervals.popFirst() {
        case .minSecond:
            switch intervals.popFirst() {
            case .majThird:
                if intervals.popFirst() == .minThird { res = Chord(root: pitches[1], type: .majSeven) }
            default: break
            }
        case .majSecond:
            switch intervals.popFirst() {
            case .minThird:
                if intervals.popFirst() == .majThird { res = Chord(root: pitches[1], type: .minSeven) }
            case .majThird:
                if intervals.isEmpty { res = Chord(root: pitches[1], type: .domSeven) }
                else { switch intervals.popFirst() {
                case .minThird: res = Chord(root: pitches[1], type: .domSeven)
                default: break
                }}
            default: break
            }
        case .minThird:
            switch intervals.popFirst() {
            case .majSecond:
                switch intervals.popFirst() {
                case .majThird: res = Chord(root: pitches[2], type: .domSeven)
                case .minThird: res = Chord(root: pitches[2], type: .minSeven)
                default: break
                }
            case .minThird:
                if intervals.isEmpty { res = Chord(root: pitches[0], type: .dim) }
                else { switch intervals.popFirst() {
                case .majSecond: res = Chord(root: pitches[3], type: .domSeven)
                default: break
                }}
            case .majThird:
                if intervals.isEmpty { res = Chord(root: pitches[0], type: .min) }
                else { switch intervals.popFirst() {
                case .minSecond: res = Chord(root: pitches[3], type: .majSeven)
                case .minThird: res = Chord(root: pitches[0], type: .minSeven)
                default: break
                }}
            case .perfFourth: if intervals.isEmpty { res = Chord(root: pitches[2], type: .maj) }
            default: break
            }
        case .majThird:
            switch intervals.popFirst() {
            case .minSecond:
                if intervals.popFirst() == .majThird { res = Chord(root: pitches[2], type: .majSeven) }
            case .minThird:
                if intervals.isEmpty { res = Chord(root: pitches[0], type: .maj) }
                else { switch intervals.popFirst() {
                case .majSecond: res = Chord(root: pitches[3], type: .minSeven)
                case .minThird: res = Chord(root: pitches[0], type: .domSeven)
                case .majThird: res = Chord(root: pitches[0], type: .majSeven)
                default: break
                }}
            case .perfFourth: if intervals.isEmpty { res = Chord(root: pitches[2], type: .min) }
            case .dimFifth: if intervals.isEmpty { res = Chord(root: pitches[0], type: .domSeven) }
            default: break
            }
        case .perfFourth:
            switch intervals.popFirst() {
            case .minThird: if intervals.isEmpty { res = Chord(root: pitches[1], type: .min) }
            case .majThird: if intervals.isEmpty { res = Chord(root: pitches[1], type: .maj) }
            default: break
            }
        case .dimFifth:
            switch intervals.popFirst() {
            case .majSecond: if intervals.isEmpty { res = Chord(root: pitches[2], type: .domSeven) }
            default: break
            }
        default: break
        }
    }
    
    guard let uRes = res else {
        return Chord(root: .defaultPitchClass, type: .none)
    }
    
    return uRes
}
