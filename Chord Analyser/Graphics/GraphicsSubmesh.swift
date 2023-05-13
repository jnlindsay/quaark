//
//  GraphicsSubmesh.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 13/5/2023.
//

import MetalKit

struct GraphicsSubmesh {
  let indexCount: Int
  let indexType: MTLIndexType
  let indexBuffer: MTLBuffer
  let indexBufferOffset: Int
  
  init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
    self.indexCount = mtkSubmesh.indexCount
    self.indexType = mtkSubmesh.indexType
    self.indexBuffer = mtkSubmesh.indexBuffer.buffer
    self.indexBufferOffset = mtkSubmesh.indexBuffer.offset
  }
}
