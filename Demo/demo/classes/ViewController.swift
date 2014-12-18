import UIKit
import Gifu

class ViewController: UIViewController {
                            
  @IBOutlet weak var animatedView: AnimatedView!
  @IBOutlet weak var button: FlatButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("mugen.gif")
    if let data = NSData(contentsOfFile: path) {
      animatedView.setAnimatedFrames(AnimatedFrame.createWithData(data, size: animatedView.frame.size))
      animatedView.resumeAnimation()
    }
    
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
  }

  @IBAction func toggleAnimation(button: UIButton) {
    if animatedView.isAnimating {
      animatedView.pauseAnimation()
      button.layer.backgroundColor = UIColor.whiteColor().CGColor
      button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    } else {
      animatedView.resumeAnimation()
      button.layer.backgroundColor = UIColor.clearColor().CGColor
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
  }
}

