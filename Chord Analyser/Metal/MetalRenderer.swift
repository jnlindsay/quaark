//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import Foundation
import simd
import MetalKit

class MetalRenderer : NSObject, MTKViewDelegate {
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = device.makeCommandQueue()!
    }
    
    func draw(in mtkView: MTKView) {
        
        // The render pass descriptor references the texture into which Metal should draw
        guard let renderPassDescriptor: MTLRenderPassDescriptor = mtkView.currentRenderPassDescriptor else { return }
        
        let commandBuffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!
        
        // Create a render pass and immediately end encoding, causing the drawable to be cleared
        let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        commandEncoder.endEncoding()
    
        // Get the drawable that will be presented at the end of the frame
        let drawable: MTLDrawable = mtkView.currentDrawable!
        
        // Request that the drawable texture be presented by the windowing system once drawing is done
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    func mtkView(_ mtkView: MTKView, drawableSizeWillChange size: CGSize) {}
    
}
