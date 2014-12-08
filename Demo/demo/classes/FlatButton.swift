import UIKit

class FlatButton: UIButton {

  let horizontalPadding: CGFloat = 14.0

  var buttonColor: UIColor?

  override init(frame: CGRect) {
    super.init(frame: frame)
    customizeAppearance()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    customizeAppearance()
  }

  override func drawRect(rect: CGRect) {
    layer.borderColor = tintColor.CGColor
    setTitleColor(tintColor, forState: UIControlState.Normal)
    setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
  }

  func customizeAppearance() {
    let containsEdgeInsets = !UIEdgeInsetsEqualToEdgeInsets(contentEdgeInsets, UIEdgeInsetsZero)
    contentEdgeInsets = containsEdgeInsets ? contentEdgeInsets : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layer.borderWidth = 2.0
    layer.borderColor = tintColor.CGColor
    layer.cornerRadius = frame.size.height / 2.0
    layer.masksToBounds = true
  }

  override var tintColor: UIColor! {
    get {
      if let color = buttonColor {
        return color
      } else {
        return super.tintColor
      }
    }
    
    set {
      super.tintColor = newValue
      buttonColor = newValue
    }
  }
}