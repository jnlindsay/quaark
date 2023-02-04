#define BUFFER_SIZE 1024

#include "CoreMIDIRealTime.h"
#import "SingleProducerSingleConsumerQueue.hpp"

typedef SingleProducerSingleConsumerQueue<MIDIEventPacket> MIDIMessageFIFO;

@implementation MIDIAdapter {
    std::unique_ptr<MIDIMessageFIFO> messageQueue;
    @public bool notes[128];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        messageQueue = std::make_unique<MIDIMessageFIFO>(BUFFER_SIZE);
    }
    return self;
}

-(bool)getNote:(int)n {
    return notes[n];
}

-(void)setNote:(int)n :(bool)value {
    notes[n] = value;
}

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                          dest:(MIDIPortRef *)outPort {

    // Create queue
    __block MIDIMessageFIFO *msgQueue = messageQueue.get();

    // Create input port
    const auto status = MIDIInputPortCreateWithProtocol(client, name, protocol, outPort, ^(const MIDIEventList *evtlist, void * __nullable srcConnRefCon) {

        if (evtlist->numPackets > 0 && msgQueue) {

            // get first event packet
            auto pkt = &evtlist->packet[0];

            for (int i = 0; i < evtlist->numPackets; ++i) {
                if (!msgQueue->push(evtlist->packet[i])) {
                    msgQueue->push(evtlist->packet[i]);
                }

                // go to next event packet
                pkt = MIDIEventPacketNext(pkt);
            }
        }
    });

    return status;
}

-(void)processBuffer:(void (^)(void))callback {
    
    if (!messageQueue) return;
    
    while (const auto message = messageQueue->pop()) {
        // Note: `message` has type std::optional<MIDIEventPacket>
        if (message.has_value()) {
            for (auto i = 0; i < message->wordCount; i++) {
                uint8_t velocity =  message->words[i]        & 0xFF;
                uint8_t status   = (message->words[i] >> 16) & 0xFF;
                uint8_t note     = (message->words[i] >> 8)  & 0xFF;
//                printf("Note: %d\n", note);
                if (status == 0x90 || status == 0x80) {
                    notes[note - 1] = (status == 0x90);
                }
                if (velocity == 0x00) {
                    printf("Velocity: %x\n", velocity);
                    notes[note - 1] = false;
                }
            }
            
            // Callback runs only if there were new messages
            callback();
            
        }
    }
    
}

//-(void)popDestinationMessages:(void (^)(const MIDIEventPacket))callback {
//    if (!messageQueue)
//        return;
//
//    while (const auto message = messageQueue->pop()) {
//        callback(*message);
//    }
//}

@end


