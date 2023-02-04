//
//  Pitch.hh
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#import <Foundation/Foundation.h>

#ifndef Pitch_hh
#define Pitch_hh

#ifdef __cplusplus

#include <string>

enum PitchClass {
    C, CSH, D, DSH, E, F, FSH, G, GSH, A, ASH, B, NONE
};
const std::string pitchClassNames[] = { "C", "D♭", "D", "E", "F#", "G", "A♭", "A", "B♭", "B", "None" };

void pitchName(PitchClass thing);

#endif /* __cplusplus */
    
@interface Pitch : NSObject

- (void)printer;

@end

#endif /* Pitch_hh */



