import UIKit
import ImageIO
import Runes

public class AnimatableImageView: UIImageView, Animatable {
  var animator: Animator?

  public var isAnimatingGIF: Bool {
    return animator?.isAnimating ?? isAnimating()
  }

  public func prepareForAnimation(imageNamed imageName: String) {
    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(imageName)
    prepareForAnimation <^> NSData(contentsOfFile: path)
  }

  public func prepareForAnimation(imageData data: NSData) {
    image = UIImage(data: data)
    animator = Animator(data: data, delegate: self)
  }

  public func animateWithImage(named imageName: String) {
    prepareForAnimation(imageNamed: imageName)
    startAnimatingGIF()
  }

  public func animateWithImageData(#data: NSData) {
    prepareForAnimation(imageData: data)
    startAnimatingGIF()
  }

  override public func displayLayer(layer: CALayer!) {
    image = animator?.currentFrame?
  }

  public func startAnimatingGIF() {
    animator?.resumeAnimation() ?? startAnimating()
  }

  public func stopAnimatingGIF() {
    animator?.pauseAnimation() ?? stopAnimating()
  }
}

