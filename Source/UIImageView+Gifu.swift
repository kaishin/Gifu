import UIKit

public extension UIImageView {
  // MARK: - Computed Properties
  var animatableImage: AnimatedImage? {
    return image as? AnimatedImage
  }

  var isAnimatingGIF: Bool {
    return animatableImage?.isAnimating() ?? isAnimating()
  }

  var animatable: Bool {
    return animatableImage != .None
  }

  // MARK: - Method Overrides
  override public func displayLayer(layer: CALayer!) {
    layer.contents = animatableImage?.currentFrame?.CGImage
  }

  // MARK: - Setter Methods
  public func setAnimatedImage(image: AnimatedImage) {
    image.delegate = self
    self.image = image
    layer.setNeedsDisplay()
  }

  // MARK: - Animation
  func startAnimatingGIF() {
    animatableImage?.resumeAnimation() ?? startAnimating()
  }

  func stopAnimatingGIF() {
    animatableImage?.pauseAnimation() ?? stopAnimating()
  }
}
