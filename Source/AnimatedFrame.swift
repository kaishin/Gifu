public struct AnimatedFrame {
  let image: UIImage?
  let duration: NSTimeInterval
}

import ImageIO
public extension AnimatedFrame {
  static func createWithData(data: NSData, size: CGSize) -> [AnimatedFrame] {
    let source = CGImageSourceCreateWithData(data, nil)
    let numberOfFrames = Int(CGImageSourceGetCount(source))

    return reduce(0..<numberOfFrames, []) { accum, index in
      let frameDuration = CGImageSourceGIFFrameDuration(source, index)
      let frameImageRef = CGImageSourceCreateImageAtIndex(source, UInt(index), nil)
      let frame = UIImage(CGImage: frameImageRef)?.resize(size)
      let animatedFrame = AnimatedFrame(image: frame, duration: frameDuration)

      return accum + [animatedFrame]
    }
  }
}
