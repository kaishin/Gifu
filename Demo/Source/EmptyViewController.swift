import UIKit
import Gifu

class EmptyViewController: UIViewController {
  let imageView = GIFImageView(image: #imageLiteral(resourceName: "mugen.gif"))

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(imageView)
  }

  override func viewDidAppear(_ animated: Bool) {
    imageView.animate(withGIFNamed: "mugen")
  }
}
