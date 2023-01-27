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
    private var source: MIDIEndpointRef
    private var timer: Timer?
    
    /// ! TODO: rewrite as class in interface
    
    // update UI
    @Published public var changed: Bool = false;
    
    // create client and port
    private var client = MIDIClientRef()
    private var outPort = MIDIPortRef()
    
    // Keep track of on/off notes
    @Published public var packetNote: UInt32?
//    @Published public var notesOn = Set<UInt32>()
    
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
            
            if self.changed { self.changed = false }
            else { self.changed = true }
            
            self.midiAdapter.processBuffer()
            
        }
    }
}
