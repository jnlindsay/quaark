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

public enum EventStatus : CustomStringConvertible {
    case noteOn
    case noteOff
    case other
    
    public var description: String {
        switch self {
        case .noteOn: return "Note on"
        case .noteOff: return "Note off"
        default: return "Other"
        }
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

@available(macOS 11.0, *)
public class CoreMIDIConnection : ObservableObject {
    // ! TODO: USE AN EXTENSION IN MAIN PROGRAM FOR OBSERVABLEOBJECT
    
    /// ! WARNING: bad API separation

    let interface = CoreMIDIInterface()
    
    // PacketReceiver.swift stuff
    public let midiAdapter = MIDIAdapter(logging: true)
    private var receiverOptions = ReceiverOptions()
    private var hasDestination: Bool = false
//    private var destination = MIDIClientRef()
    private var source: MIDIEndpointRef
    private var timer: Timer?
    
    /// ! TODO: rewrite as class in interface
    
    // Update UI
    @Published public var changed: Bool = false;
    
    // Create client
    private var client = MIDIClientRef()
    private var outPort: MIDIPortRef = 0
    
    // Keep track of on/off notes
    @Published public var packetNote: UInt32?
//    @Published public var packetStatus: MIDICVStatus?
//    @Published public var notesOn = Set<UInt32>()
    
    // messing around
    private var count: Int = 0
    
    // Keys turned "on" on the phantom keyboard.
    //   (Phantom notes are always on so that they have a "clear" colour.)
    @Published public var phantomKeyboardKeysOn: [Bool] = [
        false, false, false, false,                             // 0th octave
        false, false, false, false, false, false,               // 1st
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 2nd
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 3rd
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 4th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 5th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 6th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 7th
        false, false, false, false, false, false, false, false, // ...
        false, false, false, false, false, false,               // 8th
        false, false, false, false, false, false, false, false, // ...
        false                                                   // 9th
    ]
    
    private var midiKeyToPhantomKey = [
        // octave 0
        21: 0, 23: 2,                                                   // white
        22: 1,                                                          // black
        // octave 1
        24:  4, 26:  6, 28:  8, 29: 10, 31: 12, 33: 14, 35: 16,
        25:  5, 27:  7,         30: 11, 32: 13, 34: 15,
        // octave 2
        36: 18, 38: 20, 40: 22, 41: 24, 43: 26, 45: 28, 47: 30,
        37: 19, 39: 21,         42: 25, 44: 27, 46: 29,
        // octave 3
        48: 32, 50: 34, 52: 36, 53: 38, 55: 40, 57: 42, 59: 44,
        49: 33, 51: 35,         54: 39, 56: 41, 58: 43,
        // octave 4
        60: 46, 62: 48, 64: 50, 65: 52, 67: 54, 69: 56, 71: 58,
        61: 47, 63: 49,         66: 53, 68: 55, 70: 57,
        // octave 5
        72: 60, 74: 62, 76: 64, 77: 66, 79: 68, 81: 70, 83: 72,
        73: 61, 75: 63,         78: 67, 80: 69, 82: 71,
        // octave 6
        84: 74, 86: 76, 88: 78, 89: 80, 91: 82, 93: 84, 95: 86,
        85: 75, 87: 77,         90: 81, 92: 83, 94: 85,
        // octave 7
        96: 88, 98: 90, 100: 92, 101: 94, 103: 96, 105: 98, 107: 100,
        97: 89, 99: 91,          102: 95, 104: 97, 106: 99,
        // octave 8
        108: 102
    ]
    
    public init() {
        
        log(.coreMIDIInterface, "Initialisation has begun.")
        
        // MIDIAdapter stuff
        for i in 0..<117 {
            midiAdapter.setNote(Int32(i), false)
        }
        print("MIDIAdapter stuff:")
        print(midiAdapter.getNote(0))
        print(midiAdapter.getNote(1))
        
        // Create client
        var status = MIDIClientCreateWithBlock("Chord Analyser MIDI Client" as CFString, &client) { _ in }
        if status != noErr { print("Failed to create the MIDI client.") }
        else { log(.coreMIDIInterface, "Chord Analyser MIDI Client successfully created.") }
        
        // List devices
        let numDevices = interface.getNumberOfDevices()
        log(.coreMIDIInterface, "\(numDevices) devices found")
        for i in 0..<numDevices {
            let device = interface.getDevice(i)
            var deviceName: Unmanaged<CFString>?
            interface.objectGetStringProperty(device, kMIDIPropertyName, &deviceName)
            log(.coreMIDIInterface, "Name of device \(i): \(deviceName?.takeRetainedValue() as String?)")
        }
        
        // List external devices
        let numExternalDevices = interface.getNumberOfExternalDevices()
        log(.coreMIDIInterface, "\(numExternalDevices) external devices found")
        
        // List sources
        let numSources = interface.getNumberOfSources()
        log(.coreMIDIInterface, "\(numSources) sources found")
        for i in 0..<numSources {
            let source = interface.getSource(i)
            var sourceName: Unmanaged<CFString>?
            interface.objectGetStringProperty(source, kMIDIPropertyName, &sourceName)
            log(.coreMIDIInterface, "Name of source \(i): \(sourceName?.takeRetainedValue() as String?)")
        }
        
        // Choose source
        self.source = interface.getSource(0)
        
        setupModel()
        
        // Connect port to source
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

        
//        let status = MIDIInputPortCreateWithProtocol(self.client, destinationName as CFString, protocolID, &self.outPort) { eventList, _ in
////            print("hi", NSDate().timeIntervalSince1970)
////            print(type(of: eventList))
////            print(eventList.pointee.packet.note)
////            var packet: MIDIEventPacket = eventList.pointee.packet
////            if let note = packet.note {
////                i += 1
//////                if packet.status == .noteOn {
//////                    // TODO: remove need to unwrap
//////                    self.phantomKeyboardKeysOn[self.midiKeyToPhantomKey[Int(note)] ?? 0] = true
//////                } else if packet.status == .noteOff {
//////                    self.phantomKeyboardKeysOn[self.midiKeyToPhantomKey[Int(note)] ?? 0] = false
//////                }
////            }
//            self.count += 1
//            print("hi")
//        }
////
            if status == noErr {
                print("Successfully created the \(protocolID.description) destination with the name \(destinationName).")
//                var destinationActualName: Unmanaged<CFString>?
//                interface.objectGetStringProperty(self.destination, kMIDIPropertyName, &destinationActualName)
//                log(.coreMIDIInterface, "Name of destination: \(destinationActualName?.takeRetainedValue() as String?)")
                self.hasDestination = true
            } else {
                print("Failed to create the \(protocolID.description) destination.")
                print(String(describing: status))
            }
////        }
    }
    
    // This function calls the MIDIAdapter Objective-C++ files, which deal with realtime MIDI input.
    // MIDIAdapter.mm has functionatliy that unwraps an `evtlist` into packets, which are stuffed
    //   into a queue to be dealt with below.
    func startLogTimer() {
        log(.coreMIDIInterface, "Log timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.changed { self.changed = false }
            else { self.changed = true }
            
            self.midiAdapter.processBuffer()
            
//            print(self.midiAdapter.getCount())
            
//            print(self.count.getCount())
//            print(self.count)
            
//            self.midiAdapter.popDestinationMessages { packet in
//                log(.coreMIDIInterface, "-------------------------------")
//                log(.coreMIDIInterface, "Universal MIDI Packet \(packet.wordCount * 32) received.")
//                log(.coreMIDIInterface, "Packet: " + String(describing: MIDIMessageTypeForUPWord(packet.words.0)))
//                log(.coreMIDIInterface, "Packet data (hex): 0x\(packet.hexString)")
//                log(.coreMIDIInterface, "Packet data (bin): " + uInt32Raw(packet.words.0, true))
//                if let status = packet.status {
//                    log(.coreMIDIInterface, "Packet status: \(status.description)")
//                    //                    self.packetStatus = status/
//                } else {
//                    log(.coreMIDIInterface, "Packet status: N/A")
//                }
//            }
//            self.midiAdapter.popDestinationMessages { packet in
//                if let note = packet.note {
//                        log(.coreMIDIInterface, "Packet note: \(note)")
//                        self.packetNote = note
//
//                        // Keep track of notesOn
//                        if packet.status == .noteOn {
//                            // TODO: remove need to unwrap
//                            self.phantomKeyboardKeysOn[self.midiKeyToPhantomKey[Int(note)] ?? 0] = true
//                        } else if packet.status == .noteOff {
//                            self.phantomKeyboardKeysOn[self.midiKeyToPhantomKey[Int(note)] ?? 0] = false
//                        }
//                    } else {
//    //                    log(.coreMIDIInterface, "Packet note: N/A")
//                    }
//    //                log(.coreMIDIInterface, "-------------------------------")
//            }
            
            
        }
    }
}
