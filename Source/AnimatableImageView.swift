import ImageIO
import Runes
import UIKit

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView, Animatable {
  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?

  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return animator?.isAnimating ?? isAnimating()
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
    animator = Animator(data: data, delegate: self)
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

  /// Starts the image view animation.
  public func startAnimatingGIF() {
    animator?.resumeAnimation() ?? startAnimating()
  }

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    animator?.pauseAnimation() ?? stopAnimating()
  }
}

