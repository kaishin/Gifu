/// Responsible for parsing GIF data and decoding the individual frames.
public class Animator {

  /// Number of frame to buffer.
  var frameBufferCount = 50

  /// Specifies whether GIF frames should be resized.
  var shouldResizeFrames = false

  /// Responsible for loading individual frames and resizing them if necessary.
  var frameStore: FrameStore?

  /// Tracks whether the display link is initialized.
  private var displayLinkInitialized: Bool = false

  /// A delegate responsible for displaying the GIF frames.
  private weak var delegate: GIFAnimatable!

  /// Responsible for starting and stopping the animation.
  private lazy var displayLink: CADisplayLink = { [unowned self] in
    self.displayLinkInitialized = true
    let display = CADisplayLink(target: DisplayLinkProxy(target: self), selector: #selector(DisplayLinkProxy.onScreenUpdate))
    display.isPaused = true
    return display
  }()

  /// Introspect whether the `displayLink` is paused.
  var isAnimating: Bool {
    return !displayLink.isPaused
  }

  /// Total frame count of the GIF.
  var frameCount: Int {
    return frameStore?.frameCount ?? 0
  }

  /// Creates a new animator with a delegate.
  ///
  /// - parameter view: A view object that implements the `GIFAnimatable` protocol.
  ///
  /// - returns: A new animator instance.
  public init(withDelegate delegate: GIFAnimatable) {
    self.delegate = delegate
  }

  /// Checks if there is a new frame to display.
  fileprivate func updateFrameIfNeeded() {
    guard let store = frameStore else { return }
    store.shouldChangeFrame(with: displayLink.duration) {
      if $0 { delegate.animatorHasNewFrame() }
    }
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  func prepareForAnimation(withGIFNamed imageName: String, size: CGSize, contentMode: UIViewContentMode) {
    guard let extensionRemoved = imageName.components(separatedBy: ".")[safe: 0],
      let imagePath = Bundle.main.url(forResource: extensionRemoved, withExtension: "gif"),
      let data = try? Data(contentsOf: imagePath) else { return }

    prepareForAnimation(withGIFData: data, size: size, contentMode: contentMode)
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  func prepareForAnimation(withGIFData imageData: Data, size: CGSize, contentMode: UIViewContentMode) {
    frameStore = FrameStore(data: imageData, size: size, contentMode: contentMode, framePreloadCount: frameBufferCount)
    frameStore?.shouldResizeFrames = shouldResizeFrames
    frameStore?.prepareFrames()
    attachDisplayLink()
  }


  /// Add the display link to the main run loop.
  private func attachDisplayLink() {
    displayLink.add(to: .main, forMode: RunLoopMode.commonModes)
  }

  deinit {
    if displayLinkInitialized {
      displayLink.invalidate()
    }
  }

  /// Start animating.
  func startAnimating() {
    if frameStore?.isAnimatable ?? false {
      displayLink.isPaused = false
    }
  }

  /// Stop animating.
  func stopAnimating() {
    displayLink.isPaused = true
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  func animate(withGIFNamed imageName: String, size: CGSize, contentMode: UIViewContentMode) {
    prepareForAnimation(withGIFNamed: imageName, size: size, contentMode: contentMode)
    startAnimating()
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  func animate(withGIFData imageData: Data, size: CGSize, contentMode: UIViewContentMode) {
    prepareForAnimation(withGIFData: imageData, size: size, contentMode: contentMode)
    startAnimating()
  }

  /// Stop animating and nullify the frame store.
  func prepareForReuse() {
    stopAnimating()
    frameStore = nil
  }

  /// Gets the current image from the frame store.
  ///
  /// - returns: An optional frame image to display.
  func activeFrame() -> UIImage? {
    return frameStore?.currentFrameImage
  }
}

/// A proxy class to avoid a retain cycyle with the display link.
fileprivate class DisplayLinkProxy {

  /// The target animator.
  private weak var target: Animator?

  /// Create a new proxy object with a target animator.
  ///
  /// - parameter target: An animator instance.
  ///
  /// - returns: A new proxy instance.
  init(target: Animator) { self.target = target }

  /// Lets the target update the frame if needed.
  @objc func onScreenUpdate() { target?.updateFrameIfNeeded() }
}
