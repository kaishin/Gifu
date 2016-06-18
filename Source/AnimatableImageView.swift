import UIKit

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView {
  /// Proxy object for preventing a reference cycle between the CADisplayLink and AnimatableImageView.
  /// Source: http://merowing.info/2015/11/the-beauty-of-imperfection/
  fileprivate class TargetProxy {
    private weak var target: AnimatableImageView?

    init(target: AnimatableImageView) {
      self.target = target
    }

    @objc func onScreenUpdate() {
      target?.updateFrameIfNeeded()
    }
  }

  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?

  /// A flag to avoid invalidating the displayLink on deinit if it was never created
  private var displayLinkInitialized: Bool = false

  /// A display link that keeps calling the `updateFrame` method on every screen refresh.
  lazy var displayLink: CADisplayLink = { [unowned self] in
    self.displayLinkInitialized = true
    let display = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
    display.isPaused = true
    return display
  }()

  /// The size of the frame cache.
  public var framePreloadCount = 50

  /// Specifies whether the GIF frames should be pre-scaled to save memory. Default is **true**.
  public var needsPrescaling = true

  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return !displayLink.isPaused
  }

  /// A computed property that returns the total number of frames in the GIF.
  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  /// Prepares the frames using a GIF image file name, without starting the animation.
  /// The file name should include the `.gif` extension.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func prepareForAnimation(withGIFNamed imageName: String) {
    guard let extensionRemoved = imageName.components(separatedBy: ".")[safe: 0],
    let imagePath = Bundle.main.url(forResource: extensionRemoved, withExtension: "gif"),
      let data = try? Data(contentsOf: imagePath) else { return }

    prepareForAnimation(withGIFData: data)
  }

  /// Prepares the frames using raw GIF image data, without starting the animation.
  ///
  /// - parameter data: GIF image data.
  public func prepareForAnimation(withGIFData imageData: Data) {
    image = UIImage(data: imageData)
    animator = Animator(data: imageData, size: frame.size, contentMode: contentMode, framePreloadCount: framePreloadCount)
    animator?.needsPrescaling = needsPrescaling
    animator?.prepareFrames()
    attachDisplayLink()
  }

  /// Prepares the frames using a GIF image file name and starts animating the image view.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func animate(withGIFNamed imageName: String) {
    prepareForAnimation(withGIFNamed: imageName)
    startAnimatingGIF()
  }

  /// Prepares the frames using raw GIF image data and starts animating the image view.
  ///
  /// - parameter data: GIF image data.
  public func animate(withGIFData data: Data) {
    prepareForAnimation(withGIFData: data)
    startAnimatingGIF()
  }

  /// Updates the `image` property of the image view if necessary. This method should not be called manually.
  override public func display(_ layer: CALayer) {
    image = animator?.currentFrameImage ?? image
  }

  /// Starts the image view animation.
  public func startAnimatingGIF() {
    if animator?.isAnimatable ?? false {
      displayLink.isPaused = false
    }
  }

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    displayLink.isPaused = true
  }

  /// Reset the image view values.
  public func prepareForReuse() {
    stopAnimatingGIF()
    animator = nil
  }

  /// Update the current frame if needed.
  func updateFrameIfNeeded() {
    guard let animator = animator else { return }
    animator.shouldChangeFrame(with: displayLink.duration) { hasNewFrame in
      if hasNewFrame { self.layer.setNeedsDisplay() }
    }
  }

  /// Invalidate the displayLink so it releases its target.
  deinit {
    if displayLinkInitialized {
      displayLink.invalidate()
    }
  }

  /// Attaches the display link.
  func attachDisplayLink() {
    displayLink.add(to: .main, forMode: RunLoopMode.commonModes)
  }
}
