import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: AnimatableImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.animateWithImage(named: "mugen.gif")
  }

  @IBAction func toggleAnimation(sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
    } else {
      imageView.startAnimatingGIF()
    }
  }
}

