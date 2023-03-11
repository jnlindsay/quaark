/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An Objective-C adapter for low-level MIDI functions.
*/

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreMIDIRealTime : NSObject

-(instancetype)init;

-(OSStatus)createMIDIInputPort:(MIDIClientRef)client
                         named:(CFStringRef)name
                      protocol:(MIDIProtocolID)protocol
                       outPort:(MIDIPortRef *)outPort;

-(void)popMIDIWords:(void (^)(const uint32_t))callback;

@end

NS_ASSUME_NONNULL_END
