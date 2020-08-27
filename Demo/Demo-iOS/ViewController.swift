import UIKit
import Gifu

class ViewController: UIViewController {
  @IBOutlet weak var imageView: GIFImageView!
  @IBOutlet weak var imageDataLabel: UILabel!
  @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) { }

  var currentGIFName: String = "mugen" {
    didSet {
      self.animate()
    }
  }

  @IBAction func toggleAnimation(_ sender: AnyObject) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
      print(imageView.gifLoopDuration)
    } else {
      imageView.startAnimatingGIF()
      print(imageView.gifLoopDuration)
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
    self.animate()
  }

  func animate() {
    imageView.animate(withGIFNamed: currentGIFName, animationBlock:  {
      DispatchQueue.main.async {
        self.imageDataLabel.text = self.currentGIFName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.gifLoopDuration))s)"
      }
    })
  }
}
