import UIKit


/// Example class that conforms to `GIFAnimatable`. Uses default values for the animator frame buffer count and resize behavior.
public class GIFImageView: UIImageView, GIFAnimatable {
  public var animator: Animator?

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animator = Animator(withDelegate: self)
  }

  override public func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
}
