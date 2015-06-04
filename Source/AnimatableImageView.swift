import ImageIO
import Runes
import UIKit

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView {
  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?
  /// A display link that keeps calling the `updateFrame` method on every screen refresh.
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: Selector("updateFrame"))

  deinit {
    println("deinit animatable view")
  }

  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return !displayLink.paused
  }

  /// Prepares the frames using a GIF image file name, without starting the animation.
  /// The file name should include the `.gif` extension.
  ///
  /// :param: imageName The name of the GIF file. The method looks for the file in the app bundle.
  public func prepareForAnimation(imageNamed imageName: String) {
    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(imageName)
    prepareForAnimation <^> NSData(contentsOfFile: path)
  }

  /// Prepares the frames using raw GIF image data, without starting the animation.
  ///
  /// :param: data GIF image data.
  public func prepareForAnimation(imageData data: NSData) {
    image = UIImage(data: data)
    animator = Animator(data: data, size: frame.size, contentMode: contentMode)
    attachDisplayLink()
  }

  /// Prepares the frames using a GIF image file name and starts animating the image view.
  ///
  /// :param: imageName The name of the GIF file. The method looks for the file in the app bundle.
  public func animateWithImage(named imageName: String) {
    prepareForAnimation(imageNamed: imageName)
    startAnimatingGIF()
  }

  /// Prepares the frames using raw GIF image data and starts animating the image view.
  ///
  /// :param: data GIF image data.
  public func animateWithImageData(#data: NSData) {
    prepareForAnimation(imageData: data)
    startAnimatingGIF()
  }

  /// Updates the `UIImage` property of the image view if necessary. This method should not be called manually.
  override public func displayLayer(layer: CALayer!) {
    image = animator?.currentFrame
  }

  /// Update the current frame with the displayLink duration
  func updateFrame() {
    if animator?.updateCurrentFrame(displayLink.duration) ?? false {
      layer.setNeedsDisplay()
    }
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
    cleanup()
  }

  /// Cleanup the animator to reduce memory.
  public func cleanup() {
    image = .None
    animator = .None
  }

  /// Attaches the dsiplay link.
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}

