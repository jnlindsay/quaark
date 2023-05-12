import MetalKit

struct Quad {  
  var vertices: [Float] = [
    -1,  1, 0,
     1,  1, 0,
    -1, -1, 0,
     1, -1, 0
  ]
  
  var indices: [UInt16] = [
    0, 3, 2, //  first triangle
    0, 1, 3  // second triangle
  ]
  
  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  
  init(device: MTLDevice, scale: Float = 1) {
    vertices = vertices.map {
      $0 * scale
    }
    guard let vertexBuffer = device.makeBuffer(
      bytes: &vertices,
      length: MemoryLayout<Float>.stride * vertices.count,
      options: []
    ) else {
      fatalError("Unable to create quad vertex buffer")
    }
    self.vertexBuffer = vertexBuffer
    
    guard let indexBuffer = device.makeBuffer(
      bytes: &indices,
      length: MemoryLayout<UInt16>.stride * indices.count,
      options: []
    ) else {
      fatalError("Unable to create quad index buffer")
    }
    self.indexBuffer = indexBuffer
  }
}
