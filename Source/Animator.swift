import UIKit
import ImageIO
import Runes

/// Responsible for storing and updating the frames of a `AnimatableImageView` instance via delegation.
class Animator {
  /// Maximum duration to increment the frame timer with.
  private let maxTimeStep = 1.0
  /// An array of animated frames from a single GIF image.
  private var animatedFrames = [AnimatedFrame]()
  /// The size to resize all frames to
  private let size: CGSize
  /// The content mode to use when resizing
  private let contentMode: UIViewContentMode
  /// Maximum number of frames to load at once
  private let maxNumberOfFrames: Int
  /// The total number of frames in the GIF.
  private var numberOfFrames = 0
  /// A reference to the original image source.
  private var imageSource: CGImageSourceRef
  /// The index of the current GIF frame.
  private var currentFrameIndex = 0
  /// The index of the current GIF frame from the source.
  private var currentPreloadIndex = 0
  /// Time elapsed since the last frame change. Used to determine when the frame should be updated.
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0

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
  /// :param: data The raw GIF image data.
  /// :param: delegate An `Animatable` delegate.
  init(data: NSData, size: CGSize, contentMode: UIViewContentMode, framePreloadCount: Int) {
    let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse]
    imageSource = CGImageSourceCreateWithData(data, options)
    self.size = size
    self.contentMode = contentMode
    maxNumberOfFrames = framePreloadCount
  }

  // MARK: - Frames
  /// Loads the frames from an image source, resizes them, then caches them in `animatedFrames`.
  func prepareFrames() {
    numberOfFrames = Int(CGImageSourceGetCount(imageSource))
    let framesToProcess = min(numberOfFrames, maxNumberOfFrames)
    animatedFrames.reserveCapacity(framesToProcess)
    animatedFrames = reduce(0..<framesToProcess, []) { $0 + pure(prepareFrame($1)) }
    currentPreloadIndex = framesToProcess
  }

  /// Loads a single frame from an image source, resizes it, then returns an `AnimatedFrame`.
  ///
  /// :param: index The index of the GIF image source to prepare
  /// :returns: An AnimatedFrame object
  private func prepareFrame(index: Int) -> AnimatedFrame {
    let frameDuration = CGImageSourceGIFFrameDuration(imageSource, index)
    let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil)

    let image = UIImage(CGImage: frameImageRef)
    let scaledImage: UIImage?

    switch contentMode {
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
    return animatedFrames[index].image
  }

  /// Updates the current frame if necessary using the frame timer and the duration of each frame in `animatedFrames`.
  ///
  /// :returns: An optional image at a given frame.
  func updateCurrentFrame(duration: CFTimeInterval) -> Bool {
    timeSinceLastFrameChange += min(maxTimeStep, duration)
    var frameDuration = animatedFrames[currentFrameIndex].duration

    if timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
      let lastFrameIndex = currentFrameIndex
      currentFrameIndex = ++currentFrameIndex % animatedFrames.count

      // Loads the next needed frame for progressive loading
      if animatedFrames.count < numberOfFrames {
        animatedFrames[lastFrameIndex] = prepareFrame(currentPreloadIndex)
        currentPreloadIndex = ++currentPreloadIndex % numberOfFrames
      }
      return true
    }

    return false
  }
}
