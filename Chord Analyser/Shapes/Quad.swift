import MetalKit

struct Quad {
  
  var centre: SIMD2<Float> = SIMD2<Float>(0, 0)
  
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
  
  init(device: MTLDevice, scale: Float = 1, centre: SIMD2<Float>) {
    vertices = vertices.map {
      $0 * scale
    }
    
    // ! WARNING: BAD CODE. offset vertices
    vertices[0] += centre[0]
    vertices[3] += centre[0]
    vertices[6] += centre[0]
    vertices[9] += centre[0]
    
    vertices[1]  += centre[1]
    vertices[4]  += centre[1]
    vertices[7]  += centre[1]
    vertices[10] += centre[1]
    
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
