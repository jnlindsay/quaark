//
//  CoreMIDIConnection.m
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#define NUM_NOTES 128

#include "CoreMIDIConnection.h"
//#import "SingleProducerSingleConsumerQueue.hpp"

//typedef SingleProducerSingleConsumerQueue<MIDIEventPacket> MIDIMessageFIFO;

@implementation ObjCoreMIDIConnection {
    bool notesOn[NUM_NOTES];
}
    
- (void) initNotesToOff {
    for (int i = 0; i < NUM_NOTES; i++) {
        notesOn[i] = false;
        printf("%d", notesOn[i]);
    }
}
    
@end
