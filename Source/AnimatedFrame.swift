/// Keeps a reference to an `UIImage` instance and its duration as a GIF frame.
struct AnimatedFrame {
  let image: UIImage?
  let duration: NSTimeInterval

  static func null() -> AnimatedFrame {
    return AnimatedFrame(image: .None, duration: 0)
  }
}

