/// The protocol that view classes need to conform to to enable animated GIF support.
public protocol GIFAnimatable: class {

  /// Responsible for managing the animation frames.
  var animator: Animator? { get set }

  /// Used for displaying the animation frames.
  var image: UIImage? { get set }

  /// Notifies the instance that it needs display.
  var layer: CALayer { get }

  /// View frame used for resizing the frames.
  var frame: CGRect { get set }

  /// Content mode used for resizing the frames.
  var contentMode: UIViewContentMode { get set }
}

extension GIFAnimatable {
  /// Returns the intrinsic content size based on the size of the image.
  public var intrinsicContentSize: CGSize {
    return image?.size ?? CGSize.zero
  }

  /// Returns the active frame if available.
  public var activeFrame: UIImage? {
    return animator?.activeFrame()
  }

  /// Total frame count of the GIF.
  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  /// Introspect whether the instance is animating.
  public var isAnimatingGIF: Bool {
    return animator?.isAnimating ?? false
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  public func animate(withGIFNamed imageName: String) {
    animator?.animate(withGIFNamed: imageName, size: frame.size, contentMode: contentMode)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  public func animate(withGIFData imageData: Data) {
    animator?.animate(withGIFData: imageData, size: frame.size, contentMode: contentMode)
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  public func prepareForAnimation(withGIFNamed imageName: String) {
    animator?.prepareForAnimation(withGIFNamed: imageName, size: frame.size, contentMode: contentMode)
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  public func prepareForAnimation(withGIFData imageData: Data) {
    image = UIImage(data: imageData)
    animator?.prepareForAnimation(withGIFData: imageData, size: frame.size, contentMode: contentMode)
  }


  /// Stop animating and free up GIF data from memory.
  public func prepareForReuse() {
    animator?.prepareForReuse()
  }

  /// Start animating GIF.
  public func startAnimatingGIF() {
    animator?.startAnimating()
  }

  /// Stop animating GIF.
  public func stopAnimatingGIF() {
    animator?.stopAnimating()
  }

  /// Updates the image with a new frame if necessary.
  public func updateImageIfNeeded() {
    image = animator?.activeFrame() ?? image
  }
}

extension GIFAnimatable {
  /// Calls setNeedsDisplay on the layer whenever the animator has a new frame. Should *not* be called directly.
  func animatorHasNewFrame() {
    layer.setNeedsDisplay()
  }
}
