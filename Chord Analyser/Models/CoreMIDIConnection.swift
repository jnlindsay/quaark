//
//  File.swift
//  
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import Foundation
import CoreMIDI
import SwiftUI

private let NUM_NOTES = 128

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    
    @Published private var notesOnOff = [Bool](repeating: false, count: NUM_NOTES)
    
    private var realTime = CoreMIDIRealTime()
    private var client: MIDIClientRef
    private var port: MIDIPortRef
    private var source: MIDIEndpointRef?
    private var timer: Timer?
    
    public init() {
        
        print("--- Initialisation has begun. ---")
        
        self.client = MIDIClientRef()
        self.port = MIDIPortRef()
        self.createMIDIClient()
        self.listMIDIDevices()
        self.listMIDISources()
        if MIDIGetNumberOfSources() > 0 {
            self.source = MIDIGetSource(0)
        }
        self.createMIDIInputPort()
        self.connectPortToSource(self.port, self.source)
        self.startMIDIListener()
        
        print("--- Initialisation is complete. ---")
            
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
        let status = self.realTime.createMIDIInputPort(self.client,
                                                              named: destinationName as CFString,
                                                              protocol: MIDIProtocolID._1_0,
                                                              outPort: &self.port)
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
    
    private func startMIDIListener() {
        
        print("MIDI listener has been started.")
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
            
            self.realTime.popMIDIWords() { word in
                let note = toNote(word)
                self.updateNotesOnOff(note)
            }
        }
    }
    
    func getNotesOnOff(_ index: Int) -> Bool {
        return self.notesOnOff[index]
    }

    func updateNotesOnOff(_ note: Note) {
        /*
            Note: as of Feb 5, 2023, there must be a "single source of truth" for notes on,
                  which is currently the `notesOnOff` boolean array. Each MIDI update loop, this
                  array must be the FIRST data structure to be updated, so that others might
                  read from it afterwards.
         */
        
        if (note.status == 0x90 || note.status == 0x80) {
            // 0x90 is on, 0x80 is off
            self.notesOnOff[Int(note.note) - 1] = (note.status == 0x90)
        }
        
        if (note.velocity == 0x00) {
            self.notesOnOff[Int(note.note) - 1] = false
        }
    }

}
