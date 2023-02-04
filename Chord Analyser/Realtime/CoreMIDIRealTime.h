/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An Objective-C adapter for low-level MIDI functions.
*/

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

extern int returnAnInt();

@interface MIDIAdapter : NSObject

-(instancetype)init;

-(bool)getNote:(int)n;
-(void)setNote:(int)n :(bool)value;

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                          dest:(MIDIPortRef *)outPort;

-(void)processBuffer:(void (^)(void))callback;

//-(void)popDestinationMessages:(void (^)(const MIDIEventPacket))callback;

@end

NS_ASSUME_NONNULL_END
