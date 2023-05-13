//
//  MetalView.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 18/2/2023.
//

import SwiftUI
import MetalKit

class MetalViewController {
    
  public var view: MTKView
  public var renderer: Renderer
    
  init(world: GraphicsWorld) {
    
    // MTKView
    self.view = MTKView()
    self.view.isPaused = false
    self.view.enableSetNeedsDisplay = false
    self.view.clearColor = MTLClearColorMake(0.5, 0.5, 1.0, 1.0)

    self.renderer = Renderer(mtkView: view, world: world)
    self.renderer.mtkView(self.view, drawableSizeWillChange: self.view.drawableSize)

    self.view.delegate = self.renderer
    
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
