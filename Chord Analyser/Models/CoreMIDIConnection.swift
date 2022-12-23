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
    private let midiAdapter = MIDIAdapter(logging: true)
    private var receiverOptions = ReceiverOptions()
    private var hasDestination: Bool = false
    private var destination = MIDIClientRef()
    private var source: MIDIEndpointRef
    private var timer: Timer?
    
    /// ! TODO: rewrite as class in interface
    
    // Create client
    private var client = MIDIClientRef()
    private var outPort: MIDIPortRef = 0
    
//    @Published public var eventStatus: EventStatus = .other
//    public var eventNote: UInt32? = nil
    
    // Keep track of on/off notes
    @Published public var packetNote: UInt32?
    @Published public var packetStatus: MIDICVStatus?
    @Published public var notesOn = Set<UInt32>()
    
    // Asynchronous queue to process incoming MIDI events
//    public var readQueue = DispatchQueue.main
    
//    @Published public var noteToggle: Bool = true
    
    // Dodgy implementation of a circular bool buffer
//    @Published public var pubBoolBuffer: [Bool] = Array(repeating: false, count: 16)
//    private var boolBuffer: [Bool] = Array(repeating: false, count: 16)
//    private var boolBufferWrite: Int = 0
//    private var boolBufferRead: Int = 0
    
    // MIDIAdapter (courtesy Apple)
//    let midiAdapter = MIDIAdapter(logging = true)
    
    public init() {
        
        log(.coreMIDIInterface, "Init of CoreMIDIConnection has begun.")
        
        // Create client
        let status = MIDIClientCreateWithBlock("Chord Analyser MIDI Client" as CFString, &client) { _ in }
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
        
        // DEFAULT SOURCE (HOPEFULLY iRIG KEYS)
        var defaultSource: MIDIEndpointRef
        
        // List sources
        let numSources = interface.getNumberOfSources()
        log(.coreMIDIInterface, "\(numSources) sources found")
        defaultSource = interface.getSource(0)
        self.source = interface.getSource(0)
            // super dodgy method
        for i in 0..<numSources {
            let source = interface.getSource(i)
            var sourceName: Unmanaged<CFString>?
            interface.objectGetStringProperty(source, kMIDIPropertyName, &sourceName)
            log(.coreMIDIInterface, "Name of source \(i): \(sourceName?.takeRetainedValue() as String?)")
        }
        
        // Create default client port
//        var clientOutPort: MIDIPortRef = 0
//        self.destination = 0
        
        setupModel()
        
        // Connect to source 0 (hopefully iRig keys)
        let portConnectSourceStatus = interface.portConnectSource(
            self.outPort,
            self.source,
            &self.source
        )
        startLogTimer()
        
        // Note: as per the CoreMIDI documentation, CoreMIDI creates a high-priority receive thread
        //       on the client's behalf, and from that thread, the MIDIReceiveBlock will be called
        //       when incoming MIDI messages arrive.
        // Note: do not allocated memory in time-constraint threads.
        // Reference: SnoizeMIDI/Streams/Input Streams/InputStream, line 80
//        lazy var receiveBlock: MIDIReceiveBlock = { [weak self]
//            (evtList: UnsafePointer<MIDIEventList>,
//             srcConnRefCon: UnsafeMutableRawPointer?) in
            
//            log(.coreMIDIInterface, "-------------------------------")
//            log(.coreMIDIInterface, "Event list received.")
//            log(.coreMIDIInterface, "Event list size in bytes: " + String(MIDIEventList.sizeInBytes(pktList: evtList)))
//            log(.coreMIDIInterface, "Event list number of packets: " + String(evtList.pointee.numPackets))
//            log(.coreMIDIInterface, "Event list word count: " + String(describing: evtList.pointee.packet.wordCount))
//            log(.coreMIDIInterface, "Event list type: " + String(describing: MIDIMessageTypeForUPWord(evtList.pointee.packet.words.0)))
//            log(.coreMIDIInterface, "Event list word.0: " + String(evtList.pointee.packet.words.0))
//            log(.coreMIDIInterface, "Event list word.0: " + uInt32Raw(evtList.pointee.packet.words.0, true))
//            log(.coreMIDIInterface, "-------------------------------")
            
            // Copy data
//            let evtListSize: Int = MIDIEventList.sizeInBytes(pktList: evtList)
//            let data = Data(bytes: evtList, count: evtListSize)
//
//            let pairBuffer
            
            
            
//            if let self = self {
//
//                self.boolBuffer[self.boolBufferWrite] = false
//
//                // TODO: REWRITE AS BUFFER CLASS
//                if self.boolBufferWrite < 15 {
//                    self.boolBufferWrite += 1
//                } else {
//                    self.boolBufferWrite = 0
//                }
//
//                // Process buffer data asynchronously
//                self.readQueue.async {
//                    autoreleasepool /* why is this necessary? */ {
//
//                        for i in 0...15 {
//                            self.pubBoolBuffer[i] = self.boolBuffer[i]
//                        }
////                    log(.coreMIDIInterface, String(describing: data))
////                    log(.coreMIDIInterface, data.hexDescription)
//
////                        connection.noteToggle = connection.noteToggle ? false : true
//
//                    }
//                }
//            }
            
//            var eventStatus: MIDICVStatus? = evtList.pointee.packet.status
//            switch eventStatus {
//            case .noteOn: self.eventStatus = .noteOn
//            case .noteOff: self.eventStatus = .noteOff
//            default: self.eventStatus = .other
//            }
//            log(.coreMIDIInterface, "Event status: " + String(describing: evtList.pointee.packet.status))
//
//            var eventNote = evtList.pointee.packet.note ?? nil
//            log(.coreMIDIInterface, "Event note: " + String(describing: evtList.pointee.packet.note))
//            if let uEventNote = eventNote {
//                self.eventNote = eventNote
//                switch eventStatus {
//                case .noteOn:
//                    self.notesOn.insert(uEventNote)
//                case .noteOff:
//                    self.notesOn.remove(uEventNote)
//                default: break
//                }
//            }
//        }
//
//        let clientPortStatus = interface.inputPortCreateWithProtocol(
//            client,
//            "Chord Analyser Default OutPort" as CFString,
//            MIDIProtocolID._1_0,
//            &clientOutPort,
//            receiveBlock
//        )
        
        log(.coreMIDIInterface, "init() complete")
            
    }
    
    private func setupModel() {
        
        log(.coreMIDIInterface, "setupModel() has begun.")
        
//        receiverOptions.createMIDIInputPort = { [weak self] in
//
//            print("check")
//
//            guard let self = self else { return }
//
//            if self.hasDestination {
//                MIDIEndpointDispose(self.destination)
//            }
            
            guard let protocolID = MIDIProtocolID(rawValue: self.receiverOptions.protocolID) else { return }
            
            let destinationName = self.receiverOptions.destinationName
            
            print("Trying to create the goddamn connection...")
            
            let status = self.midiAdapter.createMIDIInputPort(self.client,
                                                                named: destinationName as CFString,
                                                                protocol: protocolID,
                                                                dest: &self.outPort)
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
//        }
    }
    
    // This function calls the MIDIAdapter Objective-C++ files, which deal with realtime MIDI input.
    // MIDIAdapter.mm has functionatliy that unwraps an `evtlist` into packets, which are stuffed
    //   into a queue to be dealt with below.
    func startLogTimer() {
        log(.coreMIDIInterface, "Log timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.midiAdapter.popDestinationMessages { packet in
                log(.coreMIDIInterface, "-------------------------------")
                log(.coreMIDIInterface, "Universal MIDI Packet \(packet.wordCount * 32) received.")
                log(.coreMIDIInterface, "Packet: " + String(describing: MIDIMessageTypeForUPWord(packet.words.0)))
                log(.coreMIDIInterface, "Packet data (hex): 0x\(packet.hexString)")
                log(.coreMIDIInterface, "Packet data (bin): " + uInt32Raw(packet.words.0, true))
                if let status = packet.status {
                    log(.coreMIDIInterface, "Packet status: \(status.description)")
                    self.packetStatus = status
                } else {
                    log(.coreMIDIInterface, "Packet status: N/A")
                }
                if let note = packet.note {
                    log(.coreMIDIInterface, "Packet note: \(note)")
                    self.packetNote = note
                    
                    // keep track of notesOn
                    if packet.status == .noteOn { self.notesOn.insert(note) }
                    else if packet.status == .noteOff { self.notesOn.remove(note) }
                    
                } else {
                    log(.coreMIDIInterface, "Packet note: N/A")
                }
                log(.coreMIDIInterface, "-------------------------------")
            }
            
            
        }
    }
    
}
