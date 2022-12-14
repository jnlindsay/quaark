//
//  Chord_AnalyserApp.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 14/12/2022.
//

import SwiftUI
import Foundation
import Logger

@main
struct Chord_AnalyserApp: App {
    
    init() {
        log(.routine, "Chord Analyser has started.")
        
//        /// ! WARNING: bad API separation
//
//        let interface = CoreMIDIInterface()
//        
//        /// ! TODO: rewrite as class in interface
//        // Create input port in client
//        var client = MIDIClientRef()
//        let status = MIDIClientCreateWithBlock("Chord Analyser MIDI Client" as CFString, &client) { _ in }
//        if status != noErr { print("Failed to create the MIDI client.") }
//        else { log(.coreMIDIInterface, "Chord Analyser MIDI Client successfully created.") }
//        
//        // List devices
//        let numDevices = interface.getNumberOfDevices()
//        log(.coreMIDIInterface, "\(numDevices) devices found")
//        for i in 0..<numDevices {
//            let device = interface.getDevice(i)
//            var deviceName: Unmanaged<CFString>?
//            interface.objectGetStringProperty(device, kMIDIPropertyName, &deviceName)
//            log(.coreMIDIInterface, "Name of device \(i): \(deviceName?.takeRetainedValue() as String?)")
//        }
//        
//        // List external devices
//        let numExternalDevices = interface.getNumberOfExternalDevices()
//        log(.coreMIDIInterface, "\(numExternalDevices) external devices found")
//        
//        // DEFAULT SOURCE (HOPEFULLY iRIG KEYS)
//        var defaultSource: MIDIEndpointRef
//        
//        // List sources
//        let numSources = interface.getNumberOfSources()
//        log(.coreMIDIInterface, "\(numSources) sources found")
//        defaultSource = interface.getSource(0)
//            // super dodgy method
//        for i in 0..<numSources {
//            let source = interface.getSource(i)
//            var sourceName: Unmanaged<CFString>?
//            interface.objectGetStringProperty(source, kMIDIPropertyName, &sourceName)
//            log(.coreMIDIInterface, "Name of source \(i): \(sourceName?.takeRetainedValue() as String?)")
//        }
//        
//        // Create default client port
//        var clientOutPort: MIDIPortRef = 0
//        var receiveBlock: MIDIReceiveBlock = {
//            (evtList: UnsafePointer<MIDIEventList>,
//             srcConnRefCon: UnsafeMutableRawPointer?) in
//            
//            log(.coreMIDIInterface, "Event received.")
//            log(.coreMIDIInterface, "Number of packets in event: " + String(evtList.pointee.numPackets))
//            log(.coreMIDIInterface, "Event word count: " + String(describing: evtList.pointee.packet.wordCount))
//            log(.coreMIDIInterface, "Event type: " + String(describing: MIDIMessageTypeForUPWord(evtList.pointee.packet.words.0)))
//            log(.coreMIDIInterface, "Event word.0: " + String(evtList.pointee.packet.words.0))
//            log(.coreMIDIInterface, "Event word.0: " + uInt32Raw(evtList.pointee.packet.words.0, true))
//            log(.coreMIDIInterface, "Event status: " + String(describing: evtList.pointee.packet.status))
//            log(.coreMIDIInterface, "Event note: " + String(describing: evtList.pointee.packet.note))
//        }
//        
//        let clientPortStatus = interface.inputPortCreateWithProtocol(
//            client,
//            "Chord Analyser Default OutPort" as CFString,
//            MIDIProtocolID._1_0,
//            &clientOutPort,
//            receiveBlock
//        )
//        
//        // Connect to source 0 (hopefully iRig keys)
//        let portConnectSourceStatus = interface.portConnectSource(
//            clientOutPort,
//            defaultSource,
//            &defaultSource
//        )
            
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
