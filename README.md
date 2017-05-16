# ![Logo](https://github.com/kaishin/Gifu/raw/master/header.gif)

[![GitHub release](https://img.shields.io/github/release/kaishin/Gifu.svg)](https://github.com/kaishin/Gifu/releases/latest) ![Bitrise](https://www.bitrise.io/app/a0eae2c9b6aa754c.svg?token=dDlRyPi2aOlZnvbl4kL8Kw&branch=master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Join the chat at https://gitter.im/kaishin/gifu](https://badges.gitter.im/kaishin/gifu.svg)](https://gitter.im/kaishin/gifu) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)

Gifu adds protocol-based, performance-aware animated GIF support to UIKit. (It's also a [prefecture in Japan](https://goo.gl/maps/CCeAc)).

⚠ **Swift 2.3** support is on the [swift2.3](https://github.com/kaishin/Gifu/tree/swift2.3) branch which will not be getting any future updates.

## Install

### [Carthage](https://github.com/Carthage/Carthage)

- Add the following to your Cartfile: `github "kaishin/Gifu"`
- Then run `carthage update`
- Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods](http://cocoapods.org)

- Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html): `pod 'Gifu'`
- You will also need to make sure you're opting into using frameworks: `use_frameworks!`
- Then run `pod install` with CocoaPods 0.36 or newer.

## How It Works

`Gifu` does not require using the built-in `GIFImageView` subclass. The `Animator` class does the heavy-lifting, while the `GIFAnimatable` protocol exposes the functionality to the view classes that conform to it, using protocol extensions.

The `Animator` has a `FrameStore` that only keeps a limited number of frames in-memory, effectively creating a buffer for the animation without consuming all the available memory. This approach makes loading large GIFs a lot more resource-friendly.

The figure below summarizes how this works in practice. Given an image
containing 10 frames, Gifu will load the current frame (red), buffer the next two frames in this example (orange), and empty up all the other frames to free up memory (gray):

<img src="https://db.tt/ZLfx23hg" width="300" />

## Usage

There are two options that should cover any situation:

- Use the built-in `GIFImageView` subclass if you don't need to combine GIF support with another image library.
- If you need more flexibility and composability, make your class conform to `GIFAnimatable`. In practice, any `UIView` subclass would do, since you get most of the required properties for free. For best results, make your `UIImageView` subclass conform to `GIFAnimatable` to get access to other features such as intrinsic content size.

### GIFAnimatable

The bread and butter of Gifu. Through protocol extensions, `GIFAnimatable` exposes all the APIs of the library, and with very little boilerplate, any class can conform to it.

~~~swift
class MyImageView: UIImageView, GIFAnimatable {
  public lazy var animator: Animator? = {
    return Animator(withDelegate: self)
  }()

  override public func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
}
~~~

That's it. Now `MyImageView` has access to all these methods and properties:

- `prepareForAnimation(withGIFNamed:)` and `prepareForAnimation(withGIFData:)` to prepare the animator property for animation.
- `startAnimatingGIF()` and `stopAnimatingGIF()` to control the animation.
- `animate(withGIFNamed:)` and `animate(withGIFData:)` to prepare for animation and start animating immediately.
- `frameCount`, `isAnimatingGIF`, and `activeFrame` to inspect the GIF view.
- `prepareForReuse()` to free up resources.
- `updateImageIfNeeded()` to update the image property if necessary.

Furthermore, you can make any class GIF-animatable, starting with `UIView` subclasses:

~~~swift
class CustomAnimatedView: UIView, GIFAnimatable {
  public lazy var animator: Animator? = {
    return Animator(withDelegate: self)
  }()

  override public func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
}
~~~

You can also make `UIKit` classes conform using associated objects may you wish:

~~~swift
import UIKit
import Gifu

extension UIImageView: GIFAnimatable {
  private struct AssociatedKeys {
    static var AnimatorKey = "gifu.animator.key"
  }

  override open func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }

  public var animator: Animator? {
    get {
      guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
        let animator = Animator(withDelegate: self)
        self.animator = animator
        return animator
      }

      return animator
    }

    set {
      objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
~~~

### Examples

The simplest way to get started is initializing a `GIFAnimatable` class in code or in a storyboard, then calling `animate(:)` on it.

~~~swift
let imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
imageView.animate(withGIFNamed: "mugen")
~~~

You can also prepare for the animation when the view loads and only start animating after a user interaction.

~~~swift
// In your view controller..

override func viewDidLoad() {
  super.viewDidLoad()
  imageView.prepareForAnimation(withGIFNamed: "mugen")
}

@IBAction func toggleAnimation(_ sender: AnyObject) {
  if imageView.isAnimatingGIF {
    imageView.stopAnimatingGIF()
  } else {
    imageView.startAnimatingGIF()
  }
}
~~~

If you are using a `GIFAnimatable` class in a table or collection view, you can call the `prepareForReuse()` method in your cell subclass:

~~~swift
override func prepareForReuse() {
  super.prepareForReuse()
  imageView.prepareForReuse()
}
~~~

### Demo App

Clone or download the repository and open `Gifu.xcworkspace` to check out the demo app.

## Documentation

See the [full API documentation](http://kaishin.github.io/Gifu/).

## Compatibility

- iOS 8.0+
- Swift 3.0
- Xcode 8.0

## License

See LICENSE.
