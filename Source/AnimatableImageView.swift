import UIKit

/// A protocol which defines methods that allow you to manage the animation progress and respond to the animation state changes.
@objc
public protocol AnimatableImageViewDelegate: class {
  /// Tells the delegate that the animation has been started at the specified index.
  /// - parameter animatableImageView: The AnimatableImageView object that is notifying the delegate about the animation starting.
  /// - parameter index: The index of the GIF's frame the animation has beed started from. 
  optional func animatableImageView(animatableImageView: AnimatableImageView, didStartAnimatingAtIndex index: Int)
  
  /// Tells the delegate that the animation has been stopped at the specified index.
  /// - parameter animatableImageView: The AnimatableImageView object that is notifying the delegate about the animation stopping.
  /// - parameter index: The index of the GIF's frame the animation has beed stopped at.
  optional func animatableImageView(animatableImageView: AnimatableImageView, didStopAnimatingAtIndex index: Int)
  
  /// Tells the delegate that currently displayed frame has beed changed.
  /// - parameter animatableImageView: The AnimatableImageView object that is notifying the delegate about the animation updates.
  /// - parameter index: The index of the GIF's frame currently displayed frame was updated to.
  optional func animatableImageView(animatableImageView: AnimatableImageView, didUpdateFrameToIndex index: Int)
  
  /// Tells the delegate that currently played animation cycle has reached the final frame.
  /// - parameter animatableImageView: The AnimatableImageView object that is notifying the delegate about the finishing of the current animation iteration.
  /// - parameter loopNumber: The number of the currently finished iteration of the animation playing.
  /// - note: Moving to a specific animation frame resets the iterations count.
  optional func animatableImageView(animatableImageView: AnimatableImageView, didReachEndOfCurrentLoop loopNumber: Int)
}

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView {
  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?
  /// A display link that keeps calling the `updateFrame` method on every screen refresh.
  lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: Selector("updateFrame"))

  /// The object that acts as the delegate of the AnimatableImageView.
  public weak var delegate: AnimatableImageViewDelegate?
  
  /// The size of the frame cache. Default is 50.
  public var framePreloadCount = 50

  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return !displayLink.paused
  }

  /// Prepares the frames using a GIF image file name, without starting the animation.
  /// The file name should include the `.gif` extension.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func prepareForAnimation(imageNamed imageName: String) {
    let imagePath = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent(imageName)
    prepareForAnimation <^> NSData(contentsOfURL: imagePath)
  }

  /// Prepares the frames using raw GIF image data, without starting the animation.
  ///
  /// - parameter data: GIF image data.
  public func prepareForAnimation(imageData data: NSData) {
    image = UIImage(data: data)
    animator = Animator(data: data, size: frame.size, contentMode: contentMode, framePreloadCount: framePreloadCount)
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

  /// Update the current frame with the displayLink duration
  func updateFrame() {
    if animator?.updateCurrentFrame(displayLink.duration) ?? false {
      layer.setNeedsDisplay()
    }
  }

  /// Invalidate the displayLink so it releases this object.
  deinit {
    displayLink.invalidate()
  }

  /// Attaches the display link.
  func attachDisplayLink() {
    displayLink.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}

