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
  let maxFrameCount: Int
  /// The total number of frames in the GIF.
  var frameCount = 0
  /// A reference to the original image source.
  var imageSource: CGImageSourceRef
  /// The index of the current GIF frame.
  var currentFrameIndex = 0
  /// The index of the current GIF frame from the source.
  var currentPreloadIndex = 0
  /// The idnex of the current GIF frame the animation was moved to. -1 means the animation wasn't moved.
  var currentMoveIndex = -1
  /// Time elapsed since the last frame change. Used to determine when the frame should be updated.
  var timeSinceLastFrameChange: NSTimeInterval = 0.0
  /// Specifies whether GIF frames should be pre-scaled.
  /// - seealso: `needsPrescaling` in AnimatableImageView.
  var needsPrescaling = true

  /// The current image frame to show.
  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
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
    self.maxFrameCount = framePreloadCount
  }

  // MARK: - Frames
  /// Loads the frames from an image source, resizes them, then caches them in `animatedFrames`.
  func prepareFrames() {
    frameCount = Int(CGImageSourceGetCount(imageSource))
    let framesToProcess = min(frameCount, maxFrameCount)
    animatedFrames.reserveCapacity(framesToProcess)
    animatedFrames = (0..<framesToProcess).reduce([]) { $0 + pure(prepareFrame($1)) }
    currentPreloadIndex = framesToProcess
  }

  /// Loads a single frame from an image source, resizes it, then returns an `AnimatedFrame`.
  ///
  /// - parameter index: The index of the GIF image source to prepare
  /// - returns: An AnimatedFrame object
  func prepareFrame(index: Int) -> AnimatedFrame {
    guard let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
      return AnimatedFrame.null()
    }

    let frameDuration = CGImageSourceGIFFrameDuration(imageSource, index: index)
    let image = UIImage(CGImage: frameImageRef)
    let scaledImage: UIImage?

    if needsPrescaling == true {
      switch contentMode {
      case .ScaleAspectFit: scaledImage = image.resizeAspectFit(size)
      case .ScaleAspectFill: scaledImage = image.resizeAspectFill(size)
      default: scaledImage = image.resize(size)
      }
    } else {
      scaledImage = image
    }

    return AnimatedFrame(image: scaledImage, duration: frameDuration)
  }
  
  /// Updates the cached frames and indices in case the animation was moved to an arbitrary frame.
  func prepareFramesAfterMoving() {
    // Check whether cache rebuilding is needed.
    if animatedFrames.count == frameCount {
      currentFrameIndex = currentMoveIndex
    } else {
      rebuildFrameCache()
    }
    
    // Reset updating time.
    timeSinceLastFrameChange = 0.0
    
    // Reset move index.
    currentMoveIndex = -1
  }

  /// Returns the frame at a particular index.
  ///
  /// - parameter index: The index of the frame.
  /// - returns: An optional image at a given frame.
  func frameAtIndex(index: Int) -> UIImage? {
    return animatedFrames[index].image
  }

  /// Updates the current frame if necessary using the frame timer and the duration of each frame in `animatedFrames`.
  ///
  /// - returns: An optional image at a given frame.
  func updateCurrentFrame(duration: CFTimeInterval) -> Bool {
    timeSinceLastFrameChange += min(maxTimeStep, duration)
    guard let frameDuration = animatedFrames[safe:currentFrameIndex]?.duration where
    frameDuration <= timeSinceLastFrameChange else { return false }

    timeSinceLastFrameChange -= frameDuration
    let lastFrameIndex = currentFrameIndex
    currentFrameIndex = ++currentFrameIndex % animatedFrames.count
    
    // Loads the next needed frame for progressive loading
    if animatedFrames.count < frameCount {
      animatedFrames[lastFrameIndex] = prepareFrame(currentPreloadIndex)
      currentPreloadIndex = ++currentPreloadIndex % frameCount
    }
    
    return true
  }
  
  /// Rebuilds cache using currentMoveIndex as the starting index.
  func rebuildFrameCache() {
    if currentMoveIndex < 0 { return }
    
    // Check whether move index matches current animation position.
    if ((currentMoveIndex + animatedFrames.count) % frameCount) == currentPreloadIndex { return }
    
    // Calculate indices of the frames that require preloading.
    var indicesForPreload = [Int](count: animatedFrames.count, repeatedValue: 0)
    var baseIndex = currentMoveIndex
    for indexForPreload in (0..<indicesForPreload.count) {
      indicesForPreload[indexForPreload] = baseIndex % frameCount
      baseIndex += 1
    }
    
    // Fill the cache with the new animated frames.
    animatedFrames = indicesForPreload.reduce([]) { $0 + pure(prepareFrame($1)) }

    // Reset currently invalid indices.
    currentPreloadIndex = baseIndex % frameCount
    currentFrameIndex = 0
  }
}
