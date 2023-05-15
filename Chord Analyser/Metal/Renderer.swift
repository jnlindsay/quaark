//
//  MetalRenderer.swift
//  Chord Analyser
//
//  Created by Jeremy Lindsay on 19/2/2023.
//

import simd
import MetalKit

class Renderer : NSObject {
  private var device: MTLDevice
    /* Do not under any circumstances change this declaration of `device`.
       It should be accessed only in this class and its derivatives. */
  private let commandQueue: MTLCommandQueue
  private let library: MTLLibrary
  private let pipelineState: MTLRenderPipelineState
//  private var world: GraphicsWorld
//  var timer: Float = 0
  
  // DODGY
  private let mesh: MTKMesh
  
  init(mtkView: MTKView, world: GraphicsWorld) {
    print("--- Renderer initialisation has begun. ---")
    
    // device
    if let newDevice = MTLCreateSystemDefaultDevice() {
      self.device = newDevice
      mtkView.device = newDevice
    } else {
      fatalError("Renderer device could not be created.")
    }
    
    // command queue
    if let newCommandQueue = self.device.makeCommandQueue() {
      self.commandQueue = newCommandQueue
    } else {
      fatalError("Command queue could not be created.")
    }

    /*
    // shader library
    if let newLibrary = self.device.makeDefaultLibrary() {
      self.library = newLibrary
    } else {
      fatalError("Shader library could not be created.")
    }
    let vertexFunction = self.library.makeFunction(name: "vertex_main")
    let fragmentFunction = self.library.makeFunction(name: "fragment_main")
     */
    
    // DODGINESS --------------------------------------------------
    
    let allocator = MTKMeshBufferAllocator(device: self.device)
    let mdlMesh = MDLMesh(
      coneWithExtent: [1,1,1],
      segments: [10, 10],
      inwardNormals: false,
      cap: true,
      geometryType: .triangles,
      allocator: allocator)
    self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
    // begin export code
    // 1
    let asset = MDLAsset()
    asset.add(mdlMesh)

    let shader = """
    #include <metal_stdlib>
    using namespace metal;

    struct VertexIn {
      float4 position [[attribute(0)]];
    };

    vertex float4
      vertex_main(const VertexIn vertex_in [[stage_in]]) {
      return vertex_in.position;
    }

    fragment float4 fragment_main() {
      return float4(1, 1, 1, 1);
    }
    """

    self.library =
      try! device.makeLibrary(source: shader, options: nil)
    let vertexFunction = library.makeFunction(name: "vertex_main")
    let fragmentFunction =
      library.makeFunction(name: "fragment_main")
    
    // END DODGINESS ----------------------------------------------
    
    // pipeline state
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
//    pipelineDescriptor.colorAttachments[0].pixelFormat =
//      mtkView.colorPixelFormat
//    do {
//      pipelineDescriptor.vertexDescriptor =
//        MTLVertexDescriptor.defaultLayout
//      self.pipelineState =
//        try self.device.makeRenderPipelineState(
//          descriptor: pipelineDescriptor
//        )
//    } catch let error {
//      fatalError(error.localizedDescription)
//    }
    
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.vertexDescriptor =
        MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
    self.pipelineState =
      try! device.makeRenderPipelineState(
        descriptor: pipelineDescriptor)
    
    // configure GraphicsWorld meshes
//    self.world = world
//    for model in self.world.models {
//      model.configureMeshes(device: self.device)
//    }

    print("--- Renderer initialisation is complete. ---")
    
  }
    
}

extension Renderer : MTKViewDelegate {
  func mtkView(
    _ mtkView: MTKView,
    drawableSizeWillChange size: CGSize
  ) {}
  
  func draw(in mtkView: MTKView) {
      
    guard
      let commandBuffer = self.commandQueue.makeCommandBuffer()
    else {
      fatalError("Command buffer could not be created.")
    }
    
//    if (mtkView.device == nil) {
//      print("OMG NO DEVICE")
//    } else {
//      print("OK DEVICE FOUND...")
//    }
//
//    if (mtkView.currentDrawable == nil) {
//      print("OMG CURRENTDRAWABLE NIL")
//    } else {
//      print("OK CURRENTDRAWALBE NOT NIL...")
//    }
    
//    let renderPassDescriptor = mtkView.currentRenderPassDescriptor
//    if (renderPassDescriptor == nil) {
//      print("OMG NIL!")
//    } else {
//      print("NOT NIL!")
//    }
    
    guard
      let renderPassDescriptor = mtkView.currentRenderPassDescriptor
    else {
      fatalError("Render pass descriptor could not be obtained.")
    }
    
    guard
      let commandEncoder = commandBuffer.makeRenderCommandEncoder(
          descriptor: renderPassDescriptor
        )
    else {
      fatalError("Command encoder could not be created.")
    }
    
    commandEncoder.setRenderPipelineState(self.pipelineState)
    
//    timer += 0.005
//    var currentTime = sin(timer)
//    commandEncoder.setVertexBytes(
//      &currentTime,
//      length: MemoryLayout<Float>.stride,
//      index: 11
//    )
    
//    for model in self.world.models {
//      model.render(commandEncoder: commandEncoder)
//    }
    
    // DODGINESS ---------------------------------------
    
    commandEncoder.setVertexBuffer(
      mesh.vertexBuffers[0].buffer,
      offset: 0,
      index: 0)

    guard let submesh = mesh.submeshes.first else {
     fatalError()
    }
    commandEncoder.setTriangleFillMode(.lines)
    commandEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: submesh.indexCount,
      indexType: submesh.indexType,
      indexBuffer: submesh.indexBuffer.buffer,
      indexBufferOffset: 0)
    
    // END DODGINESS

    commandEncoder.endEncoding()

    guard let drawable = mtkView.currentDrawable else {
      print("Renderer.swift: drawable not obtained.")
      return
    }
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
      
  }
}

protocol Renderable {
  func render(commandEncoder: MTLRenderCommandEncoder)
}
