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
    let gifs = ["mugen", "earth", "nailed"]
    if let index = gifs.firstIndex(of: currentGIFName) {
      let nextIndex = (index + 1) % gifs.count
      currentGIFName = gifs[nextIndex]
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    imageView.prepareForReuse()
  }

  override func viewDidAppear(_ animated: Bool) {
    self.animate()
  }

  func animate() {
    imageView.animate(withGIFNamed: currentGIFName, preparationBlock:  {
      DispatchQueue.main.async {
        self.imageDataLabel.text = self.currentGIFName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.gifLoopDuration))s)"
      }
    })
  }
}
