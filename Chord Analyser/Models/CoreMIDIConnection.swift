//
//  File.swift
//  
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import Foundation
import CoreMIDI
import SwiftUI

// Constants
private let NUM_NOTES = 128
private let numPrevChords = 8

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    
    // TEMP
    @Published private var notesOnOff = [Bool](repeating: false, count: NUM_NOTES)
    @Published public  var notesOn = Set<UInt8>()
    @Published public  var notesOnNames = Set<String>()
    
//    public let obj = obj()
    public var obj = ObjCoreMIDIConnection()
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
        let status = self.obj.createMIDIInputPort(self.client,
                                                          named: destinationName as CFString,
                                                          protocol: MIDIProtocolID._1_0,
                                                          dest: &self.port)
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
                print("Port successfully connected to source.")
            } else {
                print("Failed connecting port to source (ERR: \(status))")
            }
        } else {
            print("Failed connecting port to source (invalid source)")
        }
    }
    
    func startMIDIListener() {
        
        print("MIDI listener has been started.")
        
        var i = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
            
            self.obj.popMIDIWords() { word in
                let note = toNote(word)
                self.updateNotesOnOff(note)
                i += 1
//                self.updateNotesOn()
            }
            
//            self.obj.processMessage() //{
                
//                // Update keys on
//                self.keysOn = []
//                self.keysOnNames = []
//                for i in 0..<128 {
//                    if self.obj.getNote(Int32(i)) {
//                        self.keysOn.append(UInt32(i + 1))
//                        self.keysOnNames.insert(toPClass(UInt32(i + 1)).name)
//                    }
//                }
//
//                // Update chord
//                if self.keysOn.isEmpty {
//                    self.chord = (.defaultPitchClass, .none)
//                } else {
//                    self.chord = toChord(self.keysOn)
//                }
//
//                // Update chord name
//                if self.keysOn.isEmpty {
//                    self.chordName = " "
//                } else {
//                    self.chordName = chordToName(self.chord) ?? " "
//                }
//
//                // Update previous chords
//                if let uCurrNotes = self.prevNotes[mod(self.currNotesIdx, numPrevChords)] {
//                    print("idx", self.currNotesIdx)
//                    let currChord = toChord(uCurrNotes).1
//                    let nextNotes = self.keysOn
//                    let nextChord = self.chord.1
//                    print("    currChord", currChord)
//                    print("    nextChord", nextChord)
//                    if nextChord != .none && nextChord != currChord {
//                        if (nextChord == .majSeven && currChord == .maj)
//                                || (nextChord == .maj && currChord == .majSeven) {
//                            self.prevNotes[self.currNotesIdx] = nextNotes
//                        } else {
//                            print("    ...different")
//                            self.currNotesIdx = mod(self.currNotesIdx + 1, numPrevChords)
//                            self.prevNotes[self.currNotesIdx] = nextNotes
//                        }
//                    }
//                } else if self.chord.1 != .none {
//                    print(self.chord.1, "replace")
//                    self.prevNotes[self.currNotesIdx] = self.keysOn
//                }
//
//                // Update lighting
//                if self.chord.1 == .min {
//                    self.backgroundColour = .black
//                } else if self.chord.1 == .maj {
//                    self.backgroundColour = .yellow
//                } else {
//                    self.backgroundColour = .gray
//                }
//
//            }
            
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
    
    func updateNotesOn() {
        self.notesOn.removeAll(keepingCapacity: true)
        self.notesOnNames.removeAll(keepingCapacity: true)
        for (i, noteOn) in self.notesOnOff.enumerated() {
            let note = UInt8(i + 1)
            if noteOn {
                self.notesOn.insert(note)
                self.notesOnNames.insert(toPClass(note).name)
            } else {
                if self.notesOn.contains(note) {
                    self.notesOn.remove(note)
                    self.notesOnNames.insert(toPClass(note).name)
                }
            }
        }
    }

}
