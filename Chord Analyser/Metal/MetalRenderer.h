//
//  Header.h
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/2/2023.
//

#ifndef Header_h
#define Header_h

@import MetalKit;

@interface MetalRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

#endif /* Header_h */
