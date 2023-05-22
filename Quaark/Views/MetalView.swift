//
//  MetalView.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/2/2023.
//

import SwiftUI
import MetalKit

class MetalViewController {
    
  public var view: MTKViewWithNSEventBroadcaster
  public var renderer: Renderer
    
  init(world: GraphicsWorld) {
        
    self.view = MTKViewWithNSEventBroadcaster(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100)
    )
      /*
        TODO: apparently setting the frame above is bad?
        https://stackoverflow.com/questions/60737807/cametallayer-nextdrawable-returning-nil-because-allocation-failed
       */
    self.view.addListener(listener: world)
    self.view.isPaused = false
    self.view.enableSetNeedsDisplay = false
//    self.view.clearColor = MTLClearColorMake(1, 1, 1, 1)
    self.view.clearColor = MTLClearColorMake(0, 0, 0, 1)
    self.view.depthStencilPixelFormat = .depth32Float
    
    self.renderer = Renderer(metalView: self.view, world: world)
    self.view.delegate = self.renderer

    self.renderer.mtkView(self.view, drawableSizeWillChange: self.view.drawableSize)
  }
}

struct MetalView : NSViewRepresentable {
  
  public var controller: MetalViewController

  init(world: GraphicsWorld) {
    self.controller = MetalViewController(world: world)
  }
  
  func makeNSView(context: Context) -> MTKView {
    controller.renderer.draw(in: controller.view)
    return controller.view
  }
  
  func updateNSView(_ nsView: MTKView, context: Context) {
  }

}
