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
    
  private var realTime: CoreMIDIRealTime
  private var client: MIDIClientRef
  private var port: MIDIPortRef
  @Published var source: MIDIEndpointRef?
  @Published var sources: [MIDIEndpointRef : String]
  private var keyboardModel: KeyboardModel
  private var timer: Timer?
 
  init() {
      
    print("--- CoreMIDIConnection initialisation has begun. ---")
    
    self.realTime = CoreMIDIRealTime()
    self.client = MIDIClientRef()
    self.port = MIDIPortRef()
    self.keyboardModel = KeyboardModel()
    self.sources = [:]
    self.createMIDIClient()
    self.listMIDIDevices()
    self.addMIDISources()
    if MIDIGetNumberOfSources() > 0 {
        self.source = MIDIGetSource(0)
    }
    self.createMIDIInputPort()
    self.connectPortToSource(self.port, self.source)

    print("--- CoreMIDI initialisation is complete. ---")
          
  }

  private func createMIDIClient() {
    
    let notificationCallback: MIDINotifyBlock = { notificationPointer in
      let notification = notificationPointer.pointee
      
      if notification.messageID == .msgObjectAdded {
        print("MIDI device added.")
        self.reAddMIDISources()
      } else if notification.messageID == .msgObjectRemoved {
        print("MIDI device removed.")
        self.reAddMIDISources()
      }
    }
    
    let status = MIDIClientCreateWithBlock(
      "Chord Analyser MIDI Client" as CFString,
      &self.client,
      notificationCallback)
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
  
  private func addMIDISources() {
    let numSources = MIDIGetNumberOfSources()
    print("Number of MIDI sources found: \(numSources)")
    for i in 0..<numSources {
      let source = MIDIGetSource(i)
      var maybeSourceName: Unmanaged<CFString>?
      MIDIObjectGetStringProperty(source, kMIDIPropertyName, &maybeSourceName)
      if let sourceName = maybeSourceName {
        let sourceNameString = sourceName.takeRetainedValue() as String
        self.sources[source] = sourceNameString
        print("Sources: \(self.sources)")
      } else {
        print("    Name of source \(i) not found.")
      }
    }
  }
  
  private func reAddMIDISources() {
    // ! WARNING: wiping sources is potentially inefficient?
    //            probably doesn't matter
    
    self.sources = [:]
    self.addMIDISources()
    
    if let source = self.source {
      if (!self.sources.keys.contains(source)) {
        self.disconnectSource()
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
  
  private func disconnectPortFromSource() {
    if let uSource = self.source {
      let status = MIDIPortDisconnectSource(self.port, uSource)
      if status == noErr {
        self.source = nil
        print("Port successfully disconnected to source \(uSource).")
      } else {
        print("Failed disconnecting port from source (ERR: \(status))")
      }
    } else {
      print("Port not connected to source.")
        // NOTE: sometimes self.source is deliberately nil; maybe this `else` is pointless
    }
  }
  
  func startMIDIListener() {
    print("MIDI listener has been started.")

    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
        
      guard let self = self else { return }
      
      self.realTime.popMIDIWords() { word in
        let note = toNote(word)
        self.keyboardModel.updateKeyboardState(note)
      }
    }
  }
  
  func disconnectSource() {
    disconnectPortFromSource()
  }
  
  func changeSourceTo(source: MIDIEndpointRef) {
    disconnectPortFromSource()
    connectPortToSource(self.port, source) // TODO: HANDLE ERRORS!
    self.source = source
  }
  
  func getKeyboardModel() -> KeyboardModel {
    return self.keyboardModel
  }

}
