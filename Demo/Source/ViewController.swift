import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: GIFImageView!
  @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) { }

  var currentGIFName: String = "mugen" {
    didSet {
      imageView.animate(withGIFNamed: currentGIFName)
    }
  }

  @IBAction func toggleAnimation(_ sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
    } else {
      imageView.startAnimatingGIF()
    }
  }

  @IBAction func swapImage(_ sender: AnyObject) {
    switch currentGIFName {
    case "mugen":
      currentGIFName = "earth"
    default:
      currentGIFName = "mugen"
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    imageView.prepareForReuse()
  }

  override func viewDidAppear(_ animated: Bool) {
//    imageView.animate(withGIFNamed: currentGIFName)
    /// Sample gif used from gify for demo purpose only.
    imageView.animate(withURL: URL(string: "https://media.giphy.com/media/TObbUke0z8Mo/giphy.gif")!)
  }
}
