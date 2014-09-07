<img src="https://dl.dropboxusercontent.com/u/148921/logo.svg" width="100" />
Adds animated GIF support to UIKit. For the Japanese prefecture, click [here](https://goo.gl/maps/CCeAc).

#### Why?
Because Apple's `+animatedImage*` sucks, and the few third party implementations that
got it right (see [Credits](#credits)) still require you to use a `UIImageView` subclass.

#### How?

Gifu is a `UIImage` subclass and `UIImageView` extension written in Swift.
It uses `CADisplayLink` to animate the view and only keeps a limited number of
frames in-memory, which exponentially minimizes memory usage for large GIF files (+300
frames).

The figure below summarizes how this works in practice. Given an image
containing 10 frames, Gifu will load the current frame (red), pre-load the next two frames (orange),
and nullify all the other frames to free up memory (gray):

<img src="https://dl.dropboxusercontent.com/u/148921/figure.gif" width="300" />


#### Usage

Use git submodules or drag-and-drop the files in your Xcode project. I can't
believe I'm saying this in 2014.

Once done, you can call `setAnimatableImage(named:)` or
`setAnimatableImage(data:)` on your `UIImageView` (or its subclass):

```swift
let imageView = UIImageView(...)

imageView.setAnimatableImage(named: "computer-kid.gif")
// or
imageView.setAnimatableImage(data: NSData(...))
```

#### To-do

The usual suspects:

- Add documentation.
- Write some basic tests.

Nice-to-haves:

- Use Reactive Cocoa instead of (sloppy) delegation.
- Remove side effects from the private functions.

#### Credits

- The animation technique described above was originally spotted on
[OLImageView](https://github.com/ondalabs/OLImageView), then improved in [YLGIFImage](https://github.com/liyong03/YLGIFImage).

- The font used in the logo is [Azuki](http://www.myfonts.com/fonts/bluevinyl/azuki/)

- Kudos to my colleague [Tony DiPasquale](https://github.com/tonyd256) for helping out with the factory methods.

#### License

See LICENSE.
