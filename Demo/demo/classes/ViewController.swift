import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: GIFImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.animate(withGIFNamed: "mugen")
  }

  @IBAction func toggleAnimation(_ sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
    } else {
      imageView.startAnimatingGIF()
    }
  }
}
