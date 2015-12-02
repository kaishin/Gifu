# ![Gifu](https://db.tt/mZ1iMNXO)

Adds performant animated GIF support to UIKit. If you're looking for the Japanese prefecture, click [here](https://goo.gl/maps/CCeAc).

#### How?

Gifu uses a `UIImageView` subclass and an animator that keeps track of frames and their durations.

It uses `CADisplayLink` to animate the view and only keeps a limited number of
resized frames in-memory, which exponentially minimizes memory usage for large GIF files (+300 frames).

The figure below summarizes how this works in practice. Given an image
containing 10 frames, Gifu will load the current frame (red), pre-load the next two frames in this example (orange), and nullify all the other frames to free up memory (gray):

<img src="https://db.tt/ZLfx23hg" width="300" />

#### Install
#### [Carthage](https://github.com/Carthage/Carthage)

- Add the following to your Cartfile: `github "kaishin/Gifu"`
- Then run `carthage update`
- Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### [CocoaPods](http://cocoapods.org)

- Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html): `pod 'Gifu'`
- You will also need to make sure you're opting into using frameworks: `use_frameworks!`
- Then run `pod install` with CocoaPods 0.36 or newer.

#### Usage

Start by instantiating an `AnimatableImageView` either in code or Interface Builder, then call `animateWithImage(named:)` or `animateWithImageData(data:)` on it.

```swift
let imageView = AnimatableImageView(frame: CGRect(...))
imageView.animateWithImage(named: "mugen.gif")
```
You can stop the animation anytime using `imageView.stopAnimatingGIF()`, and resume
it using `imageView.startAnimatingGIF()`.

The `isAnimatingGIF()` method returns the current animation state of the view if it has an animatable image.

See the [full documentation](http://kaishin.github.io/gifu/).

#### Demo App

Clone or download the repository and open `Gifu.xcworkspace` to check out the demo app.

#### Compatibility

- iOS 8+

#### Roadmap

- Add ability to set the frame-rate

#### Contributors

- [Reda Lemeden](https://github.com/kaishin)
- [Tony DiPasquale](https://github.com/tonyd256)

#### Misc

- The font used in the logo is [Azuki](http://www.myfonts.com/fonts/bluevinyl/azuki/)
- The characters used in the icon and example image in the demo are from [Samurai Champloo](https://en.wikipedia.org/wiki/Samurai_Champloo).

#### License

See LICENSE.
