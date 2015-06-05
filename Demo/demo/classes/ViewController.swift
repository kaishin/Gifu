import UIKit
import Gifu

class ViewController: UIViewController {
                            
  @IBOutlet weak var imageView: AnimatableImageView!
  @IBOutlet weak var button: FlatButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.animateWithImage(named: "mugen.gif")

    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
  }

  @IBAction func toggleAnimation(button: UIButton) {
    if imageView.isAnimatingGIF {
      imageView.stopAnimatingGIF()
      button.layer.backgroundColor = UIColor.whiteColor().CGColor
      button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    } else {
      imageView.startAnimatingGIF()
      button.layer.backgroundColor = UIColor.clearColor().CGColor
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
  }

  @IBAction func toggleGIF(sender: UISegmentedControl) {
    imageView.stopAnimatingGIF()

    switch sender.selectedSegmentIndex {
    case 0: imageView.animateWithImage(named: "mugen.gif")
    case 1: imageView.animateWithImage(named: "almost_nailed_it.gif")
    default: imageView.image = .None
    }
  }
}

