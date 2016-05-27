import UIKit
import ImageIO

/// Responsible for storing and updating the frames of a `AnimatableImageView` instance via delegation.
class Animator {
  /// Maximum duration to increment the frame timer with.
  let maxTimeStep = 1.0
  /// An array of animated frames from a single GIF image.
  var animatedFrames = [AnimatedFrame]()
  /// The size to resize all frames to
  let size: CGSize
  /// The content mode to use when resizing
  let contentMode: UIViewContentMode
  /// Maximum number of frames to load at once
  let preloadFrameCount: Int
  /// The total number of frames in the GIF.
  var frameCount = 0
  /// A reference to the original image source.
  var imageSource: CGImageSourceRef

  /// The index of the current GIF frame.
  var currentFrameIndex = 0 {
    didSet {
      previousFrameIndex = oldValue
    }
  }

  /// The index of the previous GIF frame.
  var previousFrameIndex = 0 {
    didSet {
      dispatch_async(preloadFrameQueue) {
        self.updatePreloadedFrames()
      }
    }
  }
  /// Time elapsed since the last frame change. Used to determine when the frame should be updated.
  var timeSinceLastFrameChange: NSTimeInterval = 0.0
  /// Specifies whether GIF frames should be pre-scaled.
  /// - seealso: `needsPrescaling` in AnimatableImageView.
  var needsPrescaling = true
  /// Dispatch queue used for preloading images.
  private lazy var preloadFrameQueue = dispatch_queue_create("co.kaishin.Gifu.preloadQueue", DISPATCH_QUEUE_SERIAL)

  /// The current image frame to show.
  var currentFrameImage: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  /// The current frame duration
  var currentFrameDuration: NSTimeInterval {
    return durationAtIndex(currentFrameIndex)
  }

  /// Is this image animatable?
  var isAnimatable: Bool {
    return imageSource.isAnimatedGIF
  }

  /// Initializes an animator instance from raw GIF image data and an `Animatable` delegate.
  ///
  /// - parameter data: The raw GIF image data.
  /// - parameter delegate: An `Animatable` delegate.
  init(data: NSData, size: CGSize, contentMode: UIViewContentMode, framePreloadCount: Int) {
    let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse]
    self.imageSource = CGImageSourceCreateWithData(data, options) ?? CGImageSourceCreateIncremental(options)
    self.size = size
    self.contentMode = contentMode
    self.preloadFrameCount = framePreloadCount
  }

  // MARK: - Frames
  /// Loads the frames from an image source, resizes them, then caches them in `animatedFrames`.
  func prepareFrames(completionHandler: (Void -> Void)? = .None) {
    frameCount = Int(CGImageSourceGetCount(imageSource))
    animatedFrames.reserveCapacity(frameCount)
    dispatch_async(preloadFrameQueue) {
      self.setupAnimatedFrames()
      if let handler = completionHandler { handler() }
    }
  }

  /// Returns the frame at a particular index.
  ///
  /// - parameter index: The index of the frame.
  /// - returns: An optional image at a given frame.
  func frameAtIndex(index: Int) -> UIImage? {
    return animatedFrames[safe: index]?.image
  }

  /// Returns the duration at a particular index.
  ///
  /// - parameter index: The index of the duration.
  /// - returns: The duration of the given frame.
  func durationAtIndex(index: Int) -> NSTimeInterval {
	return animatedFrames[safe: index]?.duration ?? NSTimeInterval.infinity
  }

  /// Checks whether the frame should be changed and calls a handler with the results.
  ///
  /// - parameter duration: A `CFTimeInterval` value that will be used to determine whether frame should be changed.
  /// - parameter handler: A function that takes a `Bool` and returns nothing. It will be called with the frame change result.
  func shouldChangeFrame(duration: CFTimeInterval, handler: Bool -> Void) {
    incrementTimeSinceLastFrameChangeWithDuration(duration)

    if currentFrameDuration > timeSinceLastFrameChange {
      handler(false)
    } else {
      resetTimeSinceLastFrameChange()
      incrementCurrentFrameIndex()
      handler(true)
    }
  }
}

private extension Animator {
  /// Whether preloading is needed or not.
  var preloadingIsNeeded: Bool {
    return preloadFrameCount < frameCount - 1
  }

  /// Optionally loads a single frame from an image source, resizes it if requierd, then returns an `UIImage`.
  ///
  /// - parameter index: The index of the frame to load.
  /// - returns: An optional `UIImage` instance.
  func loadFrameAtIndex(index: Int) -> UIImage? {
    guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else { return .None }
    let image = UIImage(CGImage: imageRef)
    let scaledImage: UIImage?

    if needsPrescaling {
      switch self.contentMode {
      case .ScaleAspectFit: scaledImage = image.resizeAspectFit(size)
      case .ScaleAspectFill: scaledImage = image.resizeAspectFill(size)
      default: scaledImage = image.resize(size)
      }
    } else {
      scaledImage = image
    }

    return scaledImage
  }

  /// Updates the frames by preloading new ones and replacing the previous frame with a placeholder.
  func updatePreloadedFrames() {
    if !preloadingIsNeeded { return }
    animatedFrames[previousFrameIndex] = animatedFrames[previousFrameIndex].placeholderFrame

    preloadIndexesWithStartingIndex(currentFrameIndex).forEach { index in
      let currentAnimatedFrame = animatedFrames[index]
      if !currentAnimatedFrame.isPlaceholder { return }
      animatedFrames[index] = currentAnimatedFrame.frameWithImage(loadFrameAtIndex(index))
    }
  }

  /// Increments the `timeSinceLastFrameChange` property with a given duration.
  ///
  /// - parameter duration: An `NSTimeInterval` value to increment the `timeSinceLastFrameChange` property with.
  func incrementTimeSinceLastFrameChangeWithDuration(duration: NSTimeInterval) {
    timeSinceLastFrameChange += min(maxTimeStep, duration)
  }

  /// Ensures that `timeSinceLastFrameChange` remains accurate after each frame change by substracting the `currentFrameDuration`.
  func resetTimeSinceLastFrameChange() {
    timeSinceLastFrameChange -= currentFrameDuration
  }

  /// Increments the `currentFrameIndex` property.
  func incrementCurrentFrameIndex() {
    currentFrameIndex = incrementFrameIndex(currentFrameIndex)
  }

  /// Increments a given frame index, taking into account the `frameCount` and looping when necessary.
  ///
  /// - parameter index: The `Int` value to increment.
  /// - parameter byValue: The `Int` value to increment with.
  /// - returns: A new `Int` value.
  func incrementFrameIndex(index: Int, byValue value: Int = 1) -> Int {
    return (index + value) % frameCount
  }

  /// Returns the indexes of the frames to preload based on a starting frame index.
  ///
  /// - parameter index: Starting index.
  /// - returns: An array of indexes to preload.
  func preloadIndexesWithStartingIndex(index: Int) -> [Int] {
    let nextIndex = incrementFrameIndex(index)
    let lastIndex = incrementFrameIndex(index, byValue: preloadFrameCount)

    if lastIndex >= nextIndex {
      return [Int](nextIndex...lastIndex)
    } else {
      return [Int](nextIndex..<frameCount) + [Int](0...lastIndex)
    }
  }

  /// Set up animated frames after resetting them if necessary.
  func setupAnimatedFrames() {
    resetAnimatedFrames()

    (0..<frameCount).forEach { index in
      let frameDuration = CGImageSourceGIFFrameDuration(imageSource, index: index)
      animatedFrames += [AnimatedFrame(image: .None, duration: frameDuration)]

      if index > preloadFrameCount { return }
      animatedFrames[index] = animatedFrames[index].frameWithImage(loadFrameAtIndex(index))
    }
  }

  /// Reset animated frames.
  func resetAnimatedFrames() {
    animatedFrames = []
  }
}
