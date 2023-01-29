//
//  Miscellaneous.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 29/1/2023.
//

import Foundation

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
