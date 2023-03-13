//
//  DissonanceMeasures.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/3/2023.
//

import Foundation

    
func naiveInterval(_ interval: Interval) -> Float {
    switch interval {
    case .unison:          return  0.00
    case .minSecond:       return  0.90
    case .majSecond:       return  0.45
    case .minThird:        return  0.25
    case .majThird:        return  0.20
    case .perfFourth:      return  0.15
    case .dimFifth:        return  0.30
    case .perfFifth:       return  0.10
    case .minSixth:        return  0.30
    case .majSixth:        return  0.15
    case .minSeventh:      return  0.25
    case .majSeventh:      return  0.50
    case .octave:          return  0.50
    case .defaultInterval: return -1.00
    }
}    
