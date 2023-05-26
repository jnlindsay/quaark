//
//  Settings.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 24/5/2023.
//

import Foundation

class Settings: ObservableObject {
  @Published var lightIntensity1: Float = 5
  @Published var lightIntensity2: Float = 5
  @Published var lightIntensity3: Float = 5
  @Published var emissiveStrength: Float = 0.5
}
