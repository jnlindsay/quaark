//
//  CoreMIDIConnection.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#ifndef CoreMIDIConnection_h
#define CoreMIDIConnection_h

#include <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <stdio.h>

@interface ObjCoreMIDIConnection : NSObject

-(bool)getNote:(int)n;
-(void)setNote:(int)n :(bool)value;
-(void)initNotesToOff;

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                          dest:(MIDIPortRef *)outPort;

-(void)popMIDIWords:(void (^)(uint32_t word))callback;

@end

#endif /* CoreMIDIConnection_h */
