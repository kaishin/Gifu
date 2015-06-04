import UIKit
import Gifu

class ViewController: UIViewController {
                            
  @IBOutlet weak var imageView: AnimatableImageView!
  @IBOutlet weak var button: FlatButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.animateWithImage(named: "almost_nailed_it.gif")

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
}

