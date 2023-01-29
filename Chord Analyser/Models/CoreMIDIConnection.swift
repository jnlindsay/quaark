//
//  File.swift
//  
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

// ! TODO: CONVERT THIS FILE INTO MIDIConnection, i.e. REMOVE ALL REFERENCES TO COREMIDI

import Foundation
import CoreMIDI
import Logger
import CoreMIDIInterface
import SwiftUI

// Constants
private let numPrevChords = 8

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    // ! TODO: USE AN EXTENSION IN MAIN PROGRAM FOR OBSERVABLEOBJECT
    
    /// ! WARNING: bad API separation

    let interface = CoreMIDIInterface()
    
    // PacketReceiver.swift stuff
    public let midiAdapter = MIDIAdapter(logging: true)
    private var receiverOptions = ReceiverOptions()
    private var hasDestination: Bool = false
    private var source: MIDIEndpointRef
    private var timer: Timer?
    
    /// ! TODO: rewrite as class in interface
    
    // create client and port
    private var client = MIDIClientRef()
    private var outPort = MIDIPortRef()
    
    // Keep track of on/off notes
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
        
        log(.coreMIDIInterface, "Initialisation has begun.")
        
        // all notes off by default
        for i in 0..<117 {
            midiAdapter.setNote(Int32(i), false)
        }
        
        // create client
        var status = MIDIClientCreateWithBlock("Chord Analyser MIDI Client" as CFString, &client) { _ in }
        if status != noErr { print("Failed to create the MIDI client.") }
        else { log(.coreMIDIInterface, "Chord Analyser MIDI Client successfully created.") }
        
        // list devices
        let numDevices = interface.getNumberOfDevices()
        log(.coreMIDIInterface, "\(numDevices) devices found")
        for i in 0..<numDevices {
            let device = interface.getDevice(i)
            var deviceName: Unmanaged<CFString>?
            interface.objectGetStringProperty(device, kMIDIPropertyName, &deviceName)
            log(.coreMIDIInterface, "Name of device \(i): \(deviceName?.takeRetainedValue() as String?)")
        }
        
        // list external devices
        let numExternalDevices = interface.getNumberOfExternalDevices()
        log(.coreMIDIInterface, "\(numExternalDevices) external devices found")
        
        // list sources
        let numSources = interface.getNumberOfSources()
        log(.coreMIDIInterface, "\(numSources) sources found")
        for i in 0..<numSources {
            let source = interface.getSource(i)
            var sourceName: Unmanaged<CFString>?
            interface.objectGetStringProperty(source, kMIDIPropertyName, &sourceName)
            log(.coreMIDIInterface, "Name of source \(i): \(sourceName?.takeRetainedValue() as String?)")
        }
        
        // choose source
        self.source = interface.getSource(0)
        
        setupModel()
        
        // connect port to source
        status = interface.portConnectSource(
            self.outPort,
            self.source,
            nil
        )
        print("self.outPort:", self.outPort)
        print("self.source", self.source)
        print("portConnectSource >>", String(describing: status))
        
        // Start MIDI listener
        startLogTimer()
        
        log(.coreMIDIInterface, "Initialisation is complete.")
            
    }
    
    private func setupModel() {
        
        log(.coreMIDIInterface, "setupModel() has begun.")
            
            guard let protocolID = MIDIProtocolID(rawValue: self.receiverOptions.protocolID) else { return }
            
            let destinationName = self.receiverOptions.destinationName
            
            let status = self.midiAdapter.createMIDIInputPort(self.client,
                                                                named: destinationName as CFString,
                                                                protocol: protocolID,
                                                                dest: &self.outPort)

            if status == noErr {
                print("Successfully created the \(protocolID.description) destination with the name \(destinationName).")
                self.hasDestination = true
            } else {
                print("Failed to create the \(protocolID.description) destination.")
                print(String(describing: status))
            }
    }
    
    // This function calls the MIDIAdapter Objective-C++ files, which deal with realtime MIDI input.
    // MIDIAdapter.mm has functionatliy that unwraps an `evtlist` into packets, which are stuffed
    //   into a queue to be dealt with below.
    func startLogTimer() {
        log(.coreMIDIInterface, "Log timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.midiAdapter.processBuffer() {
                
                // --------- CALLBACK ---------
                // Note: following occurs only if there were new MIDI messages to be processed.
                
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

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
