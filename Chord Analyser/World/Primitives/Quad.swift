//import MetalKit
//
//// Ideally, the vertices and indices defining a quad should be abstracted out of the class.
////   The class should contain only position and id and other idiosyncratic information.
//class Quad {
//
//  var position: simd_float2 = simd_float2(0, 0)
//
//  var vertices: [Float] = [
//  // x   y   z
//    -1,  1,  0, // 0
//     1,  1,  0, // 1
//    -1, -1,  0, // 2
//     1, -1,  0  // 3
//  ]
//
//  var indices: [UInt16] = [
//    0, 3, 2, //  first triangle
//    0, 1, 3  // second triangle
//  ]
//
//  let vertexBuffer: MTLBuffer
//  let indexBuffer: MTLBuffer
//
//  init(device: MTLDevice, scale: Float = 1, position: simd_float2) {
//    vertices = vertices.map {
//      $0 * scale
//    }
//
//    guard let vertexBuffer = device.makeBuffer(
//      bytes: &vertices,
//      length: MemoryLayout<Float>.stride * vertices.count,
//      options: []
//    ) else {
//      fatalError("Unable to create quad vertex buffer")
//    }
//    self.vertexBuffer = vertexBuffer
//
//    guard let indexBuffer = device.makeBuffer(
//      bytes: &indices,
//      length: MemoryLayout<UInt16>.stride * indices.count,
//      options: []
//    ) else {
//      fatalError("Unable to create quad index buffer")
//    }
//    self.indexBuffer = indexBuffer
//
//    self.
//  }
//
//  func updatePosition(x: Float, y: Float) {
//    position[0] = x
//    position[1] = y
//  }
//}
