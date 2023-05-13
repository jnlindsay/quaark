//
//  CoreMIDIConnection.swift
//  
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import Foundation
import CoreMIDI
import SwiftUI

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    
  private var realTime = CoreMIDIRealTime()
  private var client: MIDIClientRef
  private var port: MIDIPortRef
  private var source: MIDIEndpointRef?
  private var keyboardModel: KeyboardModel
  private var midiEventHandler: MIDIEventHandler
  private var timer: Timer?
  
  init(
    keyboardModel: KeyboardModel,
    midiEventHandler: MIDIEventHandler
  ) {
      
    print("--- CoreMIDIConnection initialisation has begun. ---")
    
    self.client = MIDIClientRef()
    self.port = MIDIPortRef()
    self.keyboardModel = keyboardModel
    self.midiEventHandler = midiEventHandler
    self.createMIDIClient()
    self.listMIDIDevices()
    self.listMIDISources()
    if MIDIGetNumberOfSources() > 0 {
        self.source = MIDIGetSource(0)
    }
    self.createMIDIInputPort()
    self.connectPortToSource(self.port, self.source)
    
    print("--- CoreMIDI initialisation is complete. ---")
          
  }
  
  private func createMIDIClient() {
    let status = MIDIClientCreateWithBlock("Chord Analyser MIDI Client" as CFString, &self.client) { _ in }
    if status == noErr { print("MIDI Client successfully created.") }
    else { print("Failed to create the MIDI client.") }
  }
  
  private func listMIDIDevices() {
    let numDevices = MIDIGetNumberOfDevices()
    print("Number of MIDI devices found: \(numDevices)")
    for i in 0..<numDevices {
      let device = MIDIGetDevice(i)
      var maybeDeviceName: Unmanaged<CFString>?
      MIDIObjectGetStringProperty(device, kMIDIPropertyName, &maybeDeviceName)
      if let deviceName = maybeDeviceName {
        print("    Name of device \(i): \(deviceName.takeRetainedValue() as String)")
      } else {
        print("    Name of device \(i) not found.")
      }
    }
  }
  
  private func listMIDISources() {
    let numSources = MIDIGetNumberOfSources()
    print("Number of MIDI sources found: \(numSources)")
    for i in 0..<numSources {
      let source = MIDIGetSource(i)
      var maybeSourceName: Unmanaged<CFString>?
      MIDIObjectGetStringProperty(source, kMIDIPropertyName, &maybeSourceName)
      if let sourceName = maybeSourceName {
        print("    Name of source \(i): \(sourceName.takeRetainedValue() as String)")
        print("    GET RID: source \(source)")
      } else {
        print("    Name of source \(i) not found.")
      }
    }
  }
  
  private func createMIDIInputPort() {
    let destinationName = "Default destination name"
    let status = self.realTime.createMIDIInputPort(
      self.client,
      named: destinationName as CFString,
      protocol: MIDIProtocolID._1_0,
      outPort: &self.port
    )
    
    if status == noErr {
      print("MIDI input port successfully created at \(self.port).")
    } else {
      print("Failed creating MIDI input port.")
    }
  }
  
  private func connectPortToSource(_ port: MIDIPortRef, _ source: MIDIEndpointRef?) {
    if let uSource = source {
      let status = MIDIPortConnectSource(port, uSource, nil)
      if status == noErr {
        print("Port successfully connected to source \(uSource).")
      } else {
        print("Failed connecting port to source (ERR: \(status))")
      }
    } else {
      print("Failed connecting port to source (invalid source)")
    }
  }
  
  func startMIDIListener() {
    print("MIDI listener has been started.")

    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
        
      guard let self = self else { return }
      
      self.realTime.popMIDIWords() { word in
        let note = toNote(word)
        
        // ! WARNING: DUPLICATION. The MIDI event handler should be the only function below.
        self.keyboardModel.updateKeyboardState(note)
        self.midiEventHandler.propagateEvent(note)
      }
    }
  }

}
