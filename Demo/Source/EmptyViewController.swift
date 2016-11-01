import UIKit
import Gifu

class EmptyViewController: UIViewController {
  let imageView = GIFImageView(image: #imageLiteral(resourceName: "mugen.gif"))

  lazy var customImageView: CustomAnimatedView = {
    return CustomAnimatedView(frame: CGRect(x: 0, y: self.view.frame.height - 200, width: 360, height: 200))
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(imageView)
    view.addSubview(customImageView)
  }

  override func viewDidAppear(_ animated: Bool) {
    imageView.animate(withGIFNamed: "mugen")
    customImageView.animate(withGIFNamed: "earth")
  }
}

class CustomAnimatedView: UIView, GIFAnimatable {
  var image: UIImage?
    
  public lazy var animator: Animator? = {
    return Animator(withDelegate: self)
  }()

  override public func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
}
