// REWRITE THIS CRAP!!!

import MetalKit

enum TextureController {
  static var textureIndex: [String : Int] = [:]
  static var textures: [MTLTexture] = []
  static var heap: MTLHeap?
  static var device: MTLDevice?
  
  static func makeTexture(
    size: CGSize,
    pixelFormat: MTLPixelFormat,
    label: String,
    storageMode: MTLStorageMode = .private,
    usage: MTLTextureUsage = [.shaderRead, .renderTarget]
  ) -> MTLTexture? {
    let width = Int(size.width)
    let height = Int(size.height)
    guard width > 0 && height > 0 else { return nil }
    let textureDesc =
      MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: pixelFormat,
        width: width,
        height: height,
        mipmapped: false)
    textureDesc.storageMode = storageMode
    textureDesc.usage = usage
    guard let texture =
      self.device!.makeTexture(descriptor: textureDesc) else {
        fatalError("Failed to create texture")
      }
    texture.label = label
    return texture
  }
}
