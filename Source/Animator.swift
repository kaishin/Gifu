import UIKit
import ImageIO
import Runes

/// Responsible for storing and updating the frames of a `AnimatableImageView` instance via delegation.
class Animator: NSObject {
  /// The animator delegate. Should conform to the `Animatable` protocol.
  let delegate: Animatable
  /// Maximum duration to increment the frame timer with.
  private let maxTimeStep = 1.0
  /// An array of animated frames from a single GIF image.
  private var animatedFrames = [AnimatedFrame]()
  /// Maximum number of frames to load at once
  private let maxNumberOfFrames = 50
  /// The total number of frames in the GIF.
  private var numberOfFrames = 0
  /// A reference to the original image source.
  private var imageSource: CGImageSourceRef
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
    imageSource = CGImageSourceCreateWithData(data, nil)
    self.delegate = delegate
    super.init()
    attachDisplayLink()
    prepareFrames()
    pauseAnimation()
  }

  deinit {
    println("deinit animator")
  }

  // MARK: - Frames
  /// Loads the frames from an image source, resizes them, then caches them in `animatedFrames`.
  private func prepareFrames() {
    numberOfFrames = Int(CGImageSourceGetCount(imageSource))
    let framesToProcess = numberOfFrames > maxNumberOfFrames ? maxNumberOfFrames : numberOfFrames
    animatedFrames.reserveCapacity(framesToProcess)
    animatedFrames = reduce(0..<framesToProcess, []) { $0 + pure(prepareFrame($1)) }
  }

  /// Loads a single frame from an image source, resizes it, then returns an `AnimatedFrame`.
  ///
  /// :param: index The index of the GIF image source to prepare
  /// :returns: An AnimatedFrame object
  private func prepareFrame(index: Int) -> AnimatedFrame {
    let frameDuration = CGImageSourceGIFFrameDuration(imageSource, index)
    let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
    let size = delegate.frame.size

    let image = UIImage(CGImage: frameImageRef)
    let scaledImage: UIImage?

    switch delegate.contentMode {
    case .ScaleAspectFit: scaledImage = image?.resizeAspectFit(size)
    case .ScaleAspectFill: scaledImage = image?.resizeAspectFill(size)
    default: scaledImage = image?.resize(size)
    }

    return AnimatedFrame(image: scaledImage, duration: frameDuration)
  }

  /// Returns the frame at a particular index.
  ///
  /// :param: index The index of the frame.
  /// :returns: An optional image at a given frame.
  private func frameAtIndex(index: Int) -> UIImage? {
    return animatedFrames[index % animatedFrames.count].image
  }

  /// Updates the current frame if necessary using the frame timer and the duration of each frame in `animatedFrames`.
  ///
  /// :returns: An optional image at a given frame.
  func updateCurrentFrame() {
    if animatedFrames.count <= 1 { return }

    timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
    var frameDuration = animatedFrames[currentFrameIndex % animatedFrames.count].duration

    if timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
      let lastFrameIndex = currentFrameIndex
      currentFrameIndex = ++currentFrameIndex % numberOfFrames
      delegate.layer.setNeedsDisplay()

      // load the next needed frame for progressive loading
      if animatedFrames.count < numberOfFrames {
        let nextFrameToLoad = (lastFrameIndex + animatedFrames.count) % numberOfFrames
        animatedFrames[lastFrameIndex % animatedFrames.count] = prepareFrame(nextFrameToLoad)
      }
    }
  }

  // MARK: - Animation
  /// Pauses the display link.
  func pauseAnimation() {
    displayLink.paused = true
  }

  /// Resumes the display link.
  func resumeAnimation() {
    if animatedFrames.count > 1 {
      displayLink.paused = false
    }
  }

  /// Attaches the dsiplay link.
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}
