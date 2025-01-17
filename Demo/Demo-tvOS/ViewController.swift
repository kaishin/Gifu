import Gifu
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var imageView: GIFImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    self.animate()
  }

  func animate() {
    imageView.animate(withGIFNamed: "mugen")
  }
}
