#define BUFFER_SIZE 1024

#include "CoreMIDIRealTime.h"
#import "SingleProducerSingleConsumerQueue.hpp"

typedef SingleProducerSingleConsumerQueue<MIDIEventPacket> MIDIMessageFIFO;

@implementation CoreMIDIRealTime {
    std::unique_ptr<MIDIMessageFIFO> messageQueue;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        messageQueue = std::make_unique<MIDIMessageFIFO>(BUFFER_SIZE);
    }
    return self;
}

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                       outPort:(MIDIPortRef *)outPort {

    __block MIDIMessageFIFO *msgQueue = messageQueue.get();

    const auto status = MIDIInputPortCreateWithProtocol(client, name, protocol, outPort, ^(const MIDIEventList *evtlist,
                                                                                           void * __nullable srcConnRefCon) {

        /*
         In this function, CoreMIDI creates a high-priority thread for us.
         */
        
        /*
         The variable `evtlist` holds MIDI packets, and each MIDI packet
         has a fixed size.
         */
        
        if (evtlist->numPackets > 0 && msgQueue) {
            const MIDIEventPacket *pkt = &evtlist->packet[0];
            for (int i = 0; i < evtlist->numPackets; ++i) {
                msgQueue->push(*pkt);
                pkt = MIDIEventPacketNext(pkt);
            }
        }
    });

    return status;
}

-(void)popMIDIWords:(void (^)(const uint32_t word))callback {
    if (!messageQueue) return;
    while (const std::optional<MIDIEventPacket> message = messageQueue->pop()) {
        if (message.has_value()) {
            for (int i = 0; i < message->wordCount; i++) {
                const uint32_t word = message->words[i];
                callback(word);
            }
        }
    }
}

@end


