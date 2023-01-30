/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An Objective-C adapter for low-level MIDI functions.
*/

#import "MIDIAdapter.h"
#import "SingleProducerSingleConsumerQueue.hpp"

typedef SingleProducerSingleConsumerQueue<MIDIEventPacket> MIDIMessageFIFO;

int returnAnInt() { return 23423; }

@implementation MIDIAdapter {
    std::unique_ptr<MIDIMessageFIFO> messageQueue;
    // keyboard notes on/off
    @public bool notes[128];
}

- (bool)getNote:(int)n {
    return notes[n];
}

- (void)setNote:(int)n :(bool)value {
    notes[n] = value;
}


- (instancetype)initWithLogging:(BOOL)queueEnabled {
    self = [super init];
    if (self) {
        if (queueEnabled) {
            messageQueue = std::make_unique<MIDIMessageFIFO>(1024);
        }
    }
    return self;
}

// MARK: - Core MIDI

-(OSStatus)createMIDIDestination:(MIDIClientRef)client named:(CFStringRef)name protocol:(MIDIProtocolID)protocol dest:(MIDIEndpointRef *)outDest {
    __block MIDIMessageFIFO *msgQueue = messageQueue.get();
    const auto status = MIDIDestinationCreateWithProtocol(client, name, protocol, outDest, ^(const MIDIEventList * _Nonnull evtlist, void * _Nullable srcConnRefCon) {

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

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client named:(CFStringRef)name protocol:(MIDIProtocolID)protocol dest:(MIDIPortRef *)outPort {

    // Create queue
    __block MIDIMessageFIFO *msgQueue = messageQueue.get();
    printf("Ring buffer created.\n");

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

-(void)popDestinationMessages:(void (^)(const MIDIEventPacket))callback {
    if (!messageQueue)
        return;

    while (const auto message = messageQueue->pop()) {
        printf("hey");
        notes[24] = true;
        notes[13] = true;
        notes[0] = true;
//        callback(*message);
    }
}

-(OSStatus)openMIDIPort:(MIDIClientRef)client named:(CFStringRef)name port:(MIDIPortRef *)outPort {
    return MIDIOutputPortCreate(client, name, outPort);
}

-(OSStatus)sendMIDI1UPMessage:(MIDIMessage_32)message port:(MIDIPortRef)port destination:(MIDIEndpointRef)destination {
    MIDIEventList eventList = {};
    MIDIEventPacket *packet = MIDIEventListInit(&eventList, kMIDIProtocol_1_0);
    packet = MIDIEventListAdd(&eventList, sizeof(MIDIEventList), packet, 0, 1, (UInt32 *)&message);
    return MIDISendEventList(port, destination, &eventList);
}

-(OSStatus)sendMIDI2Message:(MIDIMessage_64)message port:(MIDIPortRef)port destination:(MIDIEndpointRef)destination {
    MIDIEventList eventList = {};
    MIDIEventPacket *packet = MIDIEventListInit(&eventList, kMIDIProtocol_2_0);
    packet = MIDIEventListAdd(&eventList, sizeof(MIDIEventList), packet, 0, 2, (UInt32 *)&message);
    return MIDISendEventList(port, destination, &eventList);
}

@end


