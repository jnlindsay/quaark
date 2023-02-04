//
//  Pitch.m
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 4/2/2023.
//

#include "Pitch.hh"
//#include "Pitch.h"
#include <string>
#include <iostream>
#import <Foundation/Foundation.h>

void pitchName(PitchClass thing) {
    std::string res = pitchClassNames[thing];
    std::cout << res << std::endl;
    return;
}

@implementation Pitch

- (void) printer {
    std::cout << "Hello from Objective-C++" << std::endl;
}

@end
