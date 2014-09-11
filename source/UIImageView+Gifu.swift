import UIKit

extension UIImageView {
  // MARK: - Computed Properties
  var animatableImage: AnimatedImage? {
    if image is AnimatedImage {
      return image as? AnimatedImage
    } else {
      return nil
    }
  }

  var isAnimating: Bool {
    return animatableImage?.isAnimating() ?? false
  }

  var animatable: Bool {
    return animatableImage != nil
  }

  // MARK: - Method Overrides
  override public func displayLayer(layer: CALayer!) {
    if let image = animatableImage {
      if let frame = image.currentFrame {
        layer.contents = frame.CGImage
      }
    }
  }

  // MARK: - Setter Methods
  func setAnimatableImage(named name: String) {
    image = AnimatedImage.imageWithName(name, delegate: self)
    layer.setNeedsDisplay()
  }

  func setAnimatableImage(#data: NSData) {
    image = AnimatedImage.imageWithData(data, delegate: self)
    layer.setNeedsDisplay()
  }

  // MARK: - Animation
  func startAnimating() {
    if animatable {
      animatableImage!.resumeAnimation()
    }
  }

  func stopAnimating() {
    if animatable {
      animatableImage!.pauseAnimation()
    }
  }
}
