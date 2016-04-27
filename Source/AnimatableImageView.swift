import UIKit

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView {
  /// Proxy object for preventing a reference cycle between the CADisplayLink and AnimatableImageView.
  /// Source: http://merowing.info/2015/11/the-beauty-of-imperfection/
  class TargetProxy {
    private weak var target: AnimatableImageView?

    init(target: AnimatableImageView) {
      self.target = target
    }

    @objc func onScreenUpdate() {
      target?.updateFrame()
    }
  }

  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?
  /// Specifies the number of times the animation has been played.
  var playCount = 0

  /// A flag to avoid invalidating the displayLink on deinit if it was never created
  private var displayLinkInitialized: Bool = false

  /// A display link that keeps calling the `updateFrame` method on every screen refresh.
  lazy var displayLink: CADisplayLink = {
    self.displayLinkInitialized = true
    let display = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
    display.paused = true
    return display
  }()

  /// The size of the frame cache.
  public var framePreloadCount = 50

  /// The required number of times the GIF animation is to cycle though the image sequence before stopping. The default is __0__ that means repeating the animation indefinitely. __-1__ means using loop count setting extracted from the GIF data.
  public var loopCount = 0
  
  /// Specifies whether the GIF frames should be pre-scaled to save memory. Default is **true**.
  public var needsPrescaling = true

  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return !displayLink.paused
  }

  /// A computed property that returns the total number of frames in the GIF.
  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  /// Prepares the frames using a GIF image file name, without starting the animation.
  /// The file name should include the `.gif` extension.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func prepareForAnimation(imageNamed imageName: String) {
    let imagePath = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent(imageName)
    guard let data = NSData(contentsOfURL: imagePath) else { return }
    prepareForAnimation(imageData: data)
  }

  /// Prepares the frames using raw GIF image data, without starting the animation.
  ///
  /// - parameter data: GIF image data.
  public func prepareForAnimation(imageData data: NSData) {
    playCount = 0
    image = UIImage(data: data)
    animator = Animator(data: data, size: frame.size, contentMode: contentMode, framePreloadCount: framePreloadCount)
    animator?.needsPrescaling = needsPrescaling
    animator?.prepareFrames()
    attachDisplayLink()
  }

  /// Prepares the frames using a GIF image file name and starts animating the image view.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func animateWithImage(named imageName: String) {
    prepareForAnimation(imageNamed: imageName)
    startAnimatingGIF()
  }

  /// Prepares the frames using raw GIF image data and starts animating the image view.
  ///
  /// - parameter data: GIF image data.
  public func animateWithImageData(data: NSData) {
    prepareForAnimation(imageData: data)
    startAnimatingGIF()
  }

  /// Updates the `image` property of the image view if necessary. This method should not be called manually.
  override public func displayLayer(layer: CALayer) {
    image = animator?.currentFrame
    stopAnimatingIfNeeded()
  }

  /// Starts the image view animation.
  public func startAnimatingGIF() {
    if animator?.isAnimatable ?? false {
      displayLink.paused = false
    }
  }

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    displayLink.paused = true
  }

  /// Reset the image view values
  public func prepareForReuse() {
    stopAnimatingGIF()
    animator = nil
  }

  /// Stops the animation in accordance with the loop count settings.
  func stopAnimatingIfNeeded() {
    if let animator = animator {
      // Check whether the currently displayed animation frame is the last one.
      if animator.currentAnimationPosition == (animator.frameCount - 1) {
        playCount += 1
        if shouldStopLooping() == true {
          playCount = 0
          stopAnimatingGIF()
        }
      }
    }
  }
  
  /// Specifies whether all of the required animation iterations have been finished.
  /// - returns: true if the animation should stop looping, false otherwise.
  func shouldStopLooping() -> Bool {
    let sourceLoopCount = animator?.sourceLoopCount ?? 0
    if loopCount == 0 || sourceLoopCount == 0 {
      // Infinite animation loop.
      return false
    }
    
    if loopCount > 0 {
      // Control iterations with user-defined loop count.
      if loopCount == playCount { return true }
    }
    // Control iterations with loop count from the GIF data.
    else if sourceLoopCount == playCount { return true }
    
    return false
  }
  
  /// Update the current frame with the displayLink duration
  func updateFrame() {
    if animator?.updateCurrentFrame(displayLink.duration) ?? false {
      layer.setNeedsDisplay()
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
    displayLink.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}
