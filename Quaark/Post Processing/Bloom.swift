// REWRITE THIS CRAP!!!

import MetalKit
import MetalPerformanceShaders

struct Bloom {
  let label = "Bloom Filter"
  let device: MTLDevice
  var outputTexture: MTLTexture!
  var finalTexture: MTLTexture!
  
  init(device: MTLDevice) {
    self.device = device
    TextureController.device = device
  }

  mutating func resize(view: MTKView, size: CGSize) {
    outputTexture = TextureController.makeTexture(
      size: size,
      pixelFormat: view.colorPixelFormat,
      label: "Output Texture",
      usage: [.shaderRead, .shaderWrite])
    finalTexture = TextureController.makeTexture(
      size: size,
      pixelFormat: view.colorPixelFormat,
      label: "Final Texture",
      usage: [.shaderRead, .shaderWrite])
  }

  mutating func postProcess(
    view: MTKView,
    commandBuffer: MTLCommandBuffer
  ) {
    guard
      let drawableTexture =
        view.currentDrawable?.texture else { return }

    // Brightness
    let brightness = MPSImageThresholdToZero(
      device: self.device,
      thresholdValue: 0.1,
      linearGrayColorTransform: nil)
    brightness.label = "MPS brightness"
    brightness.encode(
      commandBuffer: commandBuffer,
      sourceTexture: drawableTexture,
      destinationTexture: outputTexture)

    // Gaussian Blur
    let blur = MPSImageGaussianBlur(
      device: self.device,
      sigma: 20.0)
    blur.label = "MPS blur"
    blur.encode(
      commandBuffer: commandBuffer,
      inPlaceTexture: &outputTexture,
      fallbackCopyAllocator: nil)
    let add = MPSImageAdd(device: self.device)

    // Combine original render and filtered render
    add.encode(
      commandBuffer: commandBuffer,
      primaryTexture: drawableTexture,
      secondaryTexture: outputTexture,
      destinationTexture: finalTexture)

    guard let blitEncoder = commandBuffer.makeBlitCommandEncoder()
      else { return }
    let origin = MTLOrigin(x: 0, y: 0, z: 0)
    let size = MTLSize(
      width: drawableTexture.width,
      height: drawableTexture.height,
      depth: 1)
    blitEncoder.copy(
      from: finalTexture,
      sourceSlice: 0,
      sourceLevel: 0,
      sourceOrigin: origin,
      sourceSize: size,
      to: drawableTexture,
      destinationSlice: 0,
      destinationLevel: 0,
      destinationOrigin: origin)
    blitEncoder.endEncoding()
  }
}
