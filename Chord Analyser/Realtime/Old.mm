//
//  Realtime.h
//  UniversalMIDIPacket
//
//  Created by Jeremy Lindsay on 26/1/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

//#ifndef Realtime_h
//#define Realtime_h
//
//
//#endif /* Realtime_h */

# import "Realtime.hh"

//int returnAnInt() { return 23423; }

// buffer
//const int bufferSize = 1024;
//std::array<MIDIPacket, bufferSize> buffer;
//std::atomic<int> head;
//std::atomic<int> tail;
//
//// keyboard notes on/off
//std::array<bool, 128> notes;
//
//// callback function for incoming MIDI messages
//void midiInputCallback(const MIDIPacketList *pktList, void *readProcRefCon, void *srcConnRefCon) {
//    int numPackets = pktList->numPackets;
//    for (int i = 0; i < numPackets; i++) {
//        MIDIPacket packet = pktList->packet[i];
//
//        // insert packet into buffer using atomic operation
//        int newHead = (head.load() + 1) % bufferSize;
//
//        // OMITTED: when buffer is full (should just overwrite?)
//
//        buffer[newHead] = packet;
//
//    }
//}
//
//void processBuffer() {
//    while (true) {
//        int currentTail = tail.load();
//        if (currentTail != head.load()) {
//            // data in buffer
//            int newTail = (currentTail + 1) % bufferSize;
//            if (tail.compare_exchange_strong(currentTail, newTail)) {
//                // successfully processed packet
//                MIDIPacket packet = buffer[currentTail];
//                // do something with the packet
//                if (packet.length > 0) {
//                    // extract status byte
//                    uint8_t status = packet.data[0];
//                    if (status == 0x90 || status == 0x80) {
//                        uint8_t note = packet.data[1];
//                        bool noteOn = (status == 0x90);
//                        // update notes on/off
//                        notes[note] = noteOn;
//                    }
//                }
//            }
//        }
//    }
//}

//// TEST: return a number
//int returnAnInt() { return 342536; }
