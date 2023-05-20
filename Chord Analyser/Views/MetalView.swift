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
    
    // this hacky subclass allows for user input via NSEvent
    class MTKViewOverriden : MTKView {
      weak var world: GraphicsWorld?
      
      init(frame frameRect: CGRect, world: GraphicsWorld) {
        self.world = world
        super.init(frame: frameRect, device: nil)
      }
      
      required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }
      
      override var acceptsFirstResponder: Bool { true }
      override func keyDown(with event: NSEvent) {
        self.world?.handleNSEvent(event: event, type: .keyDown)
      }
      override func keyUp(with event: NSEvent) {
        self.world?.handleNSEvent(event: event, type: .keyUp)
      }
    }
    
    // MTKViewWithEvents
    self.view = MTKViewOverriden(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      world: world
    )
      /*
        TODO: apparently setting the frame above is bad?
        https://stackoverflow.com/questions/60737807/cametallayer-nextdrawable-returning-nil-because-allocation-failed
       */
    self.view.isPaused = false
    self.view.enableSetNeedsDisplay = false
    self.view.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
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
