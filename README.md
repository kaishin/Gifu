<img src="https://db.tt/mZ1iMNXO" width="100" />

Adds performant animated GIF support to UIKit, without subclassing `UIImageView`. If you're looking for the Japanese prefecture, click [here](https://goo.gl/maps/CCeAc).

#### Why?

Because Apple's `+animatedImage*` is not meant to be used for animated GIFs (loads all the full-sized frames in memory), and the few third party implementations that got it right (see [Credits](#credits)) still require you to use a `UIImageView` subclass, which is not very flexible and might clash with other application-specific functionality.

#### How?

Gifu uses a `UIImage` subclass and `UIImageView` extension written in Swift.
It relies on `CADisplayLink` to animate the view and optimizes the frames by resizing them.

#### Install

If you use [Carthage](https://github.com/Carthage/Carthage), add this to your `cartfile`: `github "kaishin/gifu"`.

If your prefer Git submodules or want to support iOS 7, you want to add the files in `source` to your Xcode project.

#### Usage

Start by instantiating an `AnimatedImage`, then pass it to your `UIImageView`'s `setAnimatedImage`:

```swift
if let image = AnimatedImage.animatedImageWithName("mugen.gif") {
  imageView.setAnimatedImage(image)
  imageView.startAnimatingGIF()
}
```
Note that the image view will not start animating until you call `startAnimatingGIF()`
on it. You can stop the animation anytime using `stopAnimatingGIF()`, and resume
it using `startAnimatingGIF()`. These methods will fallback to UIKit's `startAnimating()` and `stopAnimating()`
if the image view has no animatable image.

Likewise, the `isAnimatingGIF()` method returns the current animation state of the view if it has an animatable image,
or UIKit's `isAnimating()` otherwise.

#### Demo App

<img src="https://db.tt/ZoUNLHGp" width="300" />

#### Compatibility

- iOS 7+

#### Roadmap

- Documentation.
- Write some basic tests.
- Add ability to pass a frame-rate argument to `startAnimatingGIF()`

#### Contributors

- [Reda Lemeden](https://github.com/kaishin)
- [Tony DiPasquale](https://github.com/tonyd256)

#### Misc

- The font used in the logo is [Azuki](http://www.myfonts.com/fonts/bluevinyl/azuki/)
- The characters used in the icon and example image in the demo are from [Samurai Champloo](https://en.wikipedia.org/wiki/Samurai_Champloo).

#### License

See LICENSE.
