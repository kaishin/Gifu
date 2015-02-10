import UIKit
import ImageIO
import Runes

/// Responsible for storing and updating the frames of a `AnimatableImageView` instance via delegation.
class Animator: NSObject {
  /// The animator delegate. Should conform to the `Animatable` protocol.
  let delegate: Animatable
  /// Maximum duration to increment the frame timer with.
  private let maxTimeStep = 1.0
  /// The total duration of the GIF image.
  private var totalDuration: NSTimeInterval = 0.0
  /// An array of animated frames from a single GIF image.
  private var animatedFrames = [AnimatedFrame]()
  /// The index of the current GIF frame.
  private var currentFrameIndex = 0
  /// Time elapsed since the last frame change. Used to determine when the frame should be updated.
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0
  /// A display link that keeps calling the `updateCurrentFrame` method on every screen refresh.
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "updateCurrentFrame")

  /// The current image frame to show.
  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  /// Returns whether the animator is animating.
  var isAnimating: Bool {
    return !displayLink.paused
  }

  /// Initializes an animator instance from raw GIF image data and an `Animatable` delegate.
  ///
  /// :param: data The raw GIF image data.
  /// :param: delegate An `Animatable` delegate.
  required init(data: NSData, delegate: Animatable) {
    let imageSource = CGImageSourceCreateWithData(data, nil)
    self.delegate = delegate
    super.init()
    attachDisplayLink()
    curry(prepareFrames) <^> imageSource <*> delegate.frame.size
    pauseAnimation()
  }

  // MARK: - Frames
  /// Loads the frames from an image source, resizes them, then caches them in `animatedFrames`.
  ///
  /// :param: imageSource The `CGImageSourceRef` image source to extract the frames from.
  /// :param: size The size to use for the cached frames.
  private func prepareFrames(imageSource: CGImageSourceRef, size: CGSize) {
    let numberOfFrames = Int(CGImageSourceGetCount(imageSource))
    animatedFrames.reserveCapacity(numberOfFrames)

    (animatedFrames, totalDuration) = reduce(0..<numberOfFrames, ([AnimatedFrame](), 0.0)) { accumulator, index in
      let accumulatedFrames = accumulator.0
      let accumulatedDuration = accumulator.1

      let frameDuration = CGImageSourceGIFFrameDuration(imageSource, index)
      let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, UInt(index), nil)
      let frame = UIImage(CGImage: frameImageRef)?.resize(size)
      let animatedFrame = AnimatedFrame(image: frame, duration: frameDuration)

      return (accumulatedFrames + [animatedFrame], accumulatedDuration + frameDuration)
    }
  }

  /// Returns the frame at a particular index.
  ///
  /// :param: index The index of the frame.
  /// :returns: An optional image at a given frame.
  private func frameAtIndex(index: Int) -> UIImage? {
    if index >= animatedFrames.count { return .None }
    return animatedFrames[index].image
  }

  /// Updates the current frame if necessary using the frame timer and the duration of each frame in `animatedFrames`.
  ///
  /// :returns: An optional image at a given frame.
  func updateCurrentFrame() {
    if totalDuration == 0 { return }

    timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
    var frameDuration = animatedFrames[currentFrameIndex].duration

    if timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
      currentFrameIndex = ++currentFrameIndex % animatedFrames.count
      delegate.layer.setNeedsDisplay()
    }
  }

  // MARK: - Animation
  /// Pauses the display link.
  func pauseAnimation() {
    displayLink.paused = true
  }

  /// Resumes the display link.
  func resumeAnimation() {
    if totalDuration > 0 {
      displayLink.paused = false
    }
  }

  /// Attaches the dsiplay link.
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}
