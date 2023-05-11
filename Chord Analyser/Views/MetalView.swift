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
    
    init() {
        self.view = MTKView()
        self.view.isPaused = false
        self.view.enableSetNeedsDisplay = false
        self.view.device = MTLCreateSystemDefaultDevice()
        self.view.clearColor = MTLClearColorMake(0.5, 0.5, 1.0, 1.0)

        self.renderer = Renderer(mtkView: view) // do we need to check !renderer, like in Objective-C?
        self.renderer.mtkView(self.view, drawableSizeWillChange: self.view.drawableSize)

        self.view.delegate = self.renderer
    }
    
    func updateView() {
    }
    
}

struct MetalView : NSViewRepresentable {
    
    let viewController = MetalViewController()
    
    func makeNSView(context: Context) -> MTKView {
        viewController.renderer.draw(in: viewController.view)
        return viewController.view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        viewController.updateView()
    }
    
}
