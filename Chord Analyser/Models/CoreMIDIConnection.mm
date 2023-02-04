//
//  CoreMIDIConnection.m
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#define NUM_NOTES 128
#define BUFFER_SIZE 1024

#include "CoreMIDIConnection.h"
#import "SingleProducerSingleConsumerQueue.hpp"

typedef SingleProducerSingleConsumerQueue<MIDIEventPacket> MIDIMessageFIFO;

@implementation ObjCoreMIDIConnection {
    std::unique_ptr<MIDIMessageFIFO> messageQueue;
    bool notesOn[NUM_NOTES];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        messageQueue = std::make_unique<MIDIMessageFIFO>(BUFFER_SIZE);
    }
    return self;
}

-(bool)getNote:(int)n {
    return notesOn[n];
}

-(void)setNote:(int)n :(bool)value {
    notesOn[n] = value;
}

-(void) initNotesToOff {
    for (int i = 0; i < NUM_NOTES; i++) {
        notesOn[i] = false;
        printf("%d", notesOn[i]);
    }
}

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                          dest:(MIDIPortRef *)outPort {

    __block MIDIMessageFIFO *msgQueue = messageQueue.get();

    // In `MIDIInputPortCreateWithProtocol`, CoreMIDI creates a high-priority thread for us.
    const auto status = MIDIInputPortCreateWithProtocol(client, name, protocol, outPort, ^(const MIDIEventList *evtlist, void * __nullable srcConnRefCon) {

        if (evtlist->numPackets > 0 && msgQueue) {
            auto pkt = &evtlist->packet[0];
            
            for (int i = 0; i < evtlist->numPackets; ++i) {
                if (!msgQueue->push(evtlist->packet[i])) {
                    msgQueue->push(evtlist->packet[i]);
                }
                pkt = MIDIEventPacketNext(pkt);
            }
        }
    });

    return status;
}

-(void)popMIDIWords:(void (^)(uint32_t word))callback {
    
    if (!messageQueue) return;

    while (const std::optional<MIDIEventPacket> message = messageQueue->pop()) {
        for (int i = 0; i < message->wordCount; i++) {
            uint32_t word = message->words[i];
            callback(word);
        }
    }
}

//-(void)updateNotesOn:(MIDIEventPacket*)message {
//    for (auto i = 0; i < message->wordCount; i++) {
//        uint8_t velocity =  message->words[i]        & 0xFF;
//        uint8_t status   = (message->words[i] >> 16) & 0xFF;
//        uint8_t note     = (message->words[i] >> 8)  & 0xFF;
//        if (status == 0x90 || status == 0x80) {
//            notesOn[note - 1] = (status == 0x90);
//        }
//        if (velocity == 0x00) {
//            notesOn[note - 1] = false;
//        }
//    }
//}
    
@end
