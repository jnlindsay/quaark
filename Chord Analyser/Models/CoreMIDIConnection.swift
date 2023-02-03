//
//  File.swift
//  
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

// ! TODO: CONVERT THIS FILE INTO MIDIConnection, i.e. REMOVE ALL REFERENCES TO COREMIDI

import Foundation
import CoreMIDI
import SwiftUI

// Constants
private let numPrevChords = 8

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    
    public let midiAdapter = MIDIAdapter(logging: true)
    private var client: MIDIClientRef
    private var port: MIDIPortRef
    private var source: MIDIEndpointRef?
    private var timer: Timer?
    
    // SwiftUI
    private var chord: (PitchClass, Chord) = (.defaultPitchClass, .none)
    private var currNotesIdx = 0
    @Published var prevNotes = [Array<UInt32>?](repeating: nil, count: numPrevChords)
    @Published public var packetNote: UInt32?
    @Published public var keysOn = Array<UInt32>()
    @Published public var keysOnNames = Set<String>()
    @Published public var chordName = " "
    
    // Visuals
    @Published public var backgroundColour: Color = .gray
    
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
        self.turnAllKeyboardNotesOff()
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
            } else {
                print("    Name of source \(i) not found.")
            }
        }
    }
    
    private func createMIDIInputPort() {
        let destinationName = "Default destination name"
        let status = self.midiAdapter.createMIDIInputPort(self.client,
                                                          named: destinationName as CFString,
                                                          protocol: MIDIProtocolID._1_0,
                                                          dest: &self.port)
        if status == noErr {
            print("MIDI input port successfully created.")
        } else {
            print("Failed creating MIDI input port.")
        }
    }
    
    private func connectPortToSource(_ port: MIDIPortRef, _ source: MIDIEndpointRef?) {
        if let uSource = source {
            let status = MIDIPortConnectSource(port, uSource, nil)
//            print("self.outPort:", self.outPort)
//            print("self.source", self.source)
            if status == noErr {
                print("Port successfully connected to source.")
            } else {
                print("Failed connecting port to source (ERR: \(status))")
            }
        } else {
            print("Failed connecting port to source (invalid source)")
        }
    }
    
    func turnAllKeyboardNotesOff() {
        for i in 0..<117 {
            midiAdapter.setNote(Int32(i), false)
        }
    }
    
    func startMIDIListener() {
        print("MIDI listener has been started.")
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
            
            self.midiAdapter.processBuffer() {
                
                // Update keys on
                self.keysOn = []
                self.keysOnNames = []
                for i in 0..<128 {
                    if self.midiAdapter.getNote(Int32(i)) {
                        self.keysOn.append(UInt32(i + 1))
                        self.keysOnNames.insert(toPClass(UInt32(i + 1)).name)
                    }
                }
                
                // Update chord
                if self.keysOn.isEmpty {
                    self.chord = (.defaultPitchClass, .none)
                } else {
                    self.chord = toChord(self.keysOn)
                }
                
                // Update chord name
                if self.keysOn.isEmpty {
                    self.chordName = " "
                } else {
                    self.chordName = chordToName(self.chord) ?? " "
                }
                
                // Update previous chords
                if let uCurrNotes = self.prevNotes[mod(self.currNotesIdx, numPrevChords)] {
                    print("idx", self.currNotesIdx)
                    let currChord = toChord(uCurrNotes).1
                    let nextNotes = self.keysOn
                    let nextChord = self.chord.1
                    print("    currChord", currChord)
                    print("    nextChord", nextChord)
                    if nextChord != .none && nextChord != currChord {
                        if (nextChord == .majSeven && currChord == .maj)
                                || (nextChord == .maj && currChord == .majSeven) {
                            self.prevNotes[self.currNotesIdx] = nextNotes
                        } else {
                            print("    ...different")
                            self.currNotesIdx = mod(self.currNotesIdx + 1, numPrevChords)
                            self.prevNotes[self.currNotesIdx] = nextNotes
                        }
                    }
                } else if self.chord.1 != .none {
                    print(self.chord.1, "replace")
                    self.prevNotes[self.currNotesIdx] = self.keysOn
                }
                
                // Update lighting
                if self.chord.1 == .min {
                    self.backgroundColour = .black
                } else if self.chord.1 == .maj {
                    self.backgroundColour = .yellow
                } else {
                    self.backgroundColour = .gray
                }
                
            }
            
        }
    }
}
