import UIKit

class ViewController: UIViewController {
                            
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var button: FlatButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.setAnimatableImage(named: "mugen.gif")
    imageView.startAnimating()
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
  }

  @IBAction func toggleAnimation(button: UIButton) {
    if imageView.isAnimating {
      imageView.stopAnimating()
      button.layer.backgroundColor = UIColor.whiteColor().CGColor
      button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    } else {
      imageView.startAnimating()
      button.layer.backgroundColor = UIColor.clearColor().CGColor
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
  }
}

