//
//  Controllable.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/5/2023.
//

import MetalKit

enum Settings {
  static var rotationSpeed: Float { 2.0 }
//  static var translationSpeed: Float { 3.0 }
}

class ControlState {
  var wKeyDown: Bool
  var aKeyDown: Bool
  var sKeyDown: Bool
  var dKeyDown: Bool
  var rotating: Bool
  
  init() {
    self.wKeyDown = false
    self.aKeyDown = false
    self.sKeyDown = false
    self.dKeyDown = false
    self.rotating = false
  }
}

protocol Controllable where Self : DeltaTransformable {
  var controlState: ControlState { get set }
}

extension Controllable {
  mutating func handleNSEvent(
    event: NSEvent,
    type: NSEventType
  ) {

    updateKeysDown(event: event, type: type)
    self.controlState.rotating =
      (   self.controlState.wKeyDown
       || self.controlState.aKeyDown
       || self.controlState.sKeyDown
       || self.controlState.dKeyDown) ?
      true : false
    
    // x rotation
    var rotationX: Float = 0
    if (self.controlState.wKeyDown || self.controlState.sKeyDown) {
      if (!self.controlState.wKeyDown) { rotationX =  Settings.rotationSpeed }
      if (!self.controlState.sKeyDown) { rotationX = -Settings.rotationSpeed }
    }
    self.deltaTransform.rotation.x = rotationX
  
    // y rotation
    var rotationY: Float = 0
    if (self.controlState.aKeyDown || self.controlState.dKeyDown) {
      if (!self.controlState.aKeyDown) { rotationY =  Settings.rotationSpeed }
      if (!self.controlState.dKeyDown) { rotationY = -Settings.rotationSpeed }
    }
    self.deltaTransform.rotation.y = rotationY
  }
  
  func updateKeysDown(event: NSEvent, type: NSEventType) {
    let keyDown: Bool = (type == .keyDown)
    
    switch event.charactersIgnoringModifiers {
    case "w":
      self.controlState.wKeyDown = keyDown
    case "a":
      self.controlState.aKeyDown = keyDown
    case "s":
      self.controlState.sKeyDown = keyDown
    case "d":
      self.controlState.dKeyDown = keyDown
    default:
      break
    }
  }
}
