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
  private var keyboardModel: KeyboardModel
    
  init(keyboardModel: KeyboardModel) {
    self.keyboardModel = keyboardModel
    
    self.view = MTKView()
    self.view.isPaused = false
    self.view.enableSetNeedsDisplay = false
    self.view.device = MTLCreateSystemDefaultDevice()
    self.view.clearColor = MTLClearColorMake(0.5, 0.5, 1.0, 1.0)

    self.renderer = Renderer(mtkView: view, keyboardModel: keyboardModel) // do we need to check !renderer, like in Objective-C?
    self.renderer.mtkView(self.view, drawableSizeWillChange: self.view.drawableSize)

    self.view.delegate = self.renderer
  }

  func updateView() {
  }
    
}

struct MetalView : NSViewRepresentable {
  
  var keyboardModel: KeyboardModel
  let viewController: MetalViewController
  
  init(keyboardModel: KeyboardModel) {
    self.keyboardModel = keyboardModel
    self.viewController = MetalViewController(keyboardModel: keyboardModel)
  }
  
  func makeNSView(context: Context) -> MTKView {
      viewController.renderer.draw(in: viewController.view)
      return viewController.view
  }
  
  func updateNSView(_ nsView: MTKView, context: Context) {
      viewController.updateView()
  }
    
}
