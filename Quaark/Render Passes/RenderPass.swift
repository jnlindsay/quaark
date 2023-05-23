//
//  RenderPass.swift
//  Quaark
//
//  Created by Jeremy Lindsay on 23/5/2023.
//

import MetalKit

protocol RenderPass {
  var label: String { get }
  var renderer: Renderer? { get set }
  var renderPassDescriptor: MTLRenderPassDescriptor? { get set }
  
  mutating func resize(metalView: MTKView, size: CGSize)
  
  func draw(
    commandBuffer: MTLCommandBuffer,
    world: GraphicsWorld,
    uniforms: Uniforms,
    parameters: Parameters
  )
}

extension RenderPass {
  static func buildDepthStencilState(
    device: MTLDevice
  ) -> MTLDepthStencilState? {
    let stencilDescriptor = MTLDepthStencilDescriptor()
    stencilDescriptor.depthCompareFunction = .less
    stencilDescriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(
      descriptor: stencilDescriptor
    )
  }
  
  static func makeTexture(
    label: String,
    size: CGSize,
    device: MTLDevice,
    pixelFormat: MTLPixelFormat,
    storageMode: MTLStorageMode = .private,
    usage: MTLTextureUsage = [.shaderRead, .renderTarget]
  ) -> MTLTexture? {
    let width = Int(size.width)
    let height = Int(size.height)
    guard width > 0 && height > 0 else { return nil }
    let textureDescriptor =
    MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: pixelFormat,
      width: width,
      height: height,
      mipmapped: false
    )
    textureDescriptor.storageMode = storageMode
    textureDescriptor.usage = usage
    guard let texture =
      device.makeTexture(descriptor: textureDescriptor)
    else {
      fatalError("Failed to create texture")
    }
    texture.label = label
    return texture
  }
}
