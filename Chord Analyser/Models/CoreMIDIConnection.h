//
//  CoreMIDIConnection.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#ifndef CoreMIDIConnection_h
#define CoreMIDIConnection_h

#include <Foundation/Foundation.h>

@interface MIDIConnectionWrapper : NSObject
@property (nonatomic, readonly) MIDIConnection *midiConnection;
- (instancetype)initWithMyClass:(MyClass*)myClass;
@end

- (void)initNotesToOff;

@end

#endif /* CoreMIDIConnection_h */
