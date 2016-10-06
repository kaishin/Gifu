import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: AnimatableImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.animateWithImage(named: "mugen1.gif")
  }

  @IBAction func toggleAnimation(_ sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
    } else {
      imageView.startAnimatingGIF()
    }
  }
}

