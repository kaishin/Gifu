import UIKit

/// Responsible for parsing GIF data and decoding the individual frames.
public class Animator {

  /// Total duration of one animation loop
  var loopDuration: TimeInterval {
    return frameStore?.loopDuration ?? 0
  }
    
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
    if store.isFinished {
        stopAnimating()
        return
    }
    
    store.shouldChangeFrame(with: displayLink.duration) {
      if $0 { delegate.animatorHasNewFrame() }
    }
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  func prepareForAnimation(withGIFNamed imageName: String, size: CGSize, contentMode: UIView.ContentMode, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    guard let extensionRemoved = imageName.components(separatedBy: ".")[safe: 0],
      let imagePath = Bundle.main.url(forResource: extensionRemoved, withExtension: "gif"),
      let data = try? Data(contentsOf: imagePath) else { return }

    prepareForAnimation(withGIFData: data,
                        size: size,
                        contentMode: contentMode,
                        loopCount: loopCount,
                        completionHandler: completionHandler)
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  func prepareForAnimation(withGIFData imageData: Data, size: CGSize, contentMode: UIView.ContentMode, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    frameStore = FrameStore(data: imageData,
                            size: size,
                            contentMode: contentMode,
                            framePreloadCount: frameBufferCount,
                            loopCount: loopCount)
    frameStore!.shouldResizeFrames = shouldResizeFrames
    frameStore!.prepareFrames(completionHandler)
    attachDisplayLink()
  }

  /// Add the display link to the main run loop.
  private func attachDisplayLink() {
    displayLink.add(to: .main, forMode: RunLoop.Mode.common)
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
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  func animate(withGIFNamed imageName: String, size: CGSize, contentMode: UIView.ContentMode, loopCount: Int = 0, completionHandler: (() -> Void)? = nil) {
    prepareForAnimation(withGIFNamed: imageName,
                        size: size,
                        contentMode: contentMode,
                        loopCount: loopCount,
                        completionHandler: completionHandler)
    startAnimating()
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter size: The target size of the individual frames.
  /// - parameter contentMode: The view content mode to use for the individual frames.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Completion callback function
  func animate(withGIFData imageData: Data, size: CGSize, contentMode: UIView.ContentMode, loopCount: Int = 0, completionHandler: (() -> Void)? = nil)  {
    prepareForAnimation(withGIFData: imageData,
                        size: size,
                        contentMode: contentMode,
                        loopCount: loopCount,
                        completionHandler: completionHandler)
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

/// A proxy class to avoid a retain cycle with the display link.
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
