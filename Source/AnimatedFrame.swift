/// Keeps a reference to an `UIImage` instance and its duration as a GIF frame.
struct AnimatedFrame {
  /// The image that should be used for this frame.
  let image: UIImage?
  /// The duration that the frame image should be displayed.
  let duration: NSTimeInterval

  /// A placeholder frame with no image assigned.
  /// Used to replace frames that are no longer needed in the animation.
  var placeholderFrame: AnimatedFrame {
    return AnimatedFrame(image: nil, duration: duration)
  }

  /// Whether the AnimatedFrame instance contains an image or not.
  var isPlaceholder: Bool {
    return image == .None
  }

  /// Takes an optional image and returns an non-placeholder `AnimatedFrame`.
  ///
  /// - parameter image: An optional `UIImage` instance to be assigned to the new frame.
  /// - returns: A non-placeholder `AnimatedFrame` instance.
  func frameWithImage(image: UIImage?) -> AnimatedFrame {
    return AnimatedFrame(image: image, duration: duration)
  }
}

