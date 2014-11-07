import UIKit
import ImageIO

class AnimatedImage: UIImage {
  // MARK: - Constants
  let framesToPreload = 10
  let maxTimeStep = 1.0

  // MARK: - Public Properties
  var delegate: UIImageView?
  var frameDurations = [NSTimeInterval]()
  var frames = [UIImage?]()
  var totalDuration: NSTimeInterval = 0.0

  // MARK: - Private Properties
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "updateCurrentFrame")
  private lazy var preloadFrameQueue = dispatch_queue_create("co.kaishin.GIFPreloadImages", DISPATCH_QUEUE_SERIAL)
  private var currentFrameIndex = 0
  private var imageSource: CGImageSource?
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0

  // MARK: - Computed Properties
  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  private var isAnimated: Bool {
    return imageSource != nil
  }

  // MARK: - Initializers
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  required init(data: NSData, delegate: UIImageView?) {
    let imageSource = CGImageSourceCreateWithData(data, nil)
    self.delegate = delegate

    if CGImageSourceContainsAnimatedGIF(imageSource) {
      super.init()
      attachDisplayLink()
      prepareFrames(imageSource)
      pauseAnimation()
    } else {
      super.init(data: data)
    }
  }

  // MARK: - Factories
  class func imageWithName(name: String, delegate: UIImageView?) -> Self? {
    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(name)

    if let data = NSData(contentsOfFile: path) {
      return imageWithData(data, delegate: delegate)
    }

    return nil
  }

  class func imageWithData(data: NSData, delegate: UIImageView?) -> Self? {
    return self(data: data, delegate: delegate)
  }

  // MARK: - Display Link Helpers
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }

  // MARK: - Frame Methods
  private func prepareFrames(source: CGImageSource!) {
    imageSource = source

    let numberOfFrames = Int(CGImageSourceGetCount(self.imageSource))
    frameDurations.reserveCapacity(numberOfFrames)
    frames.reserveCapacity(numberOfFrames)

    for index in 0..<numberOfFrames {
      let frameDuration = CGImageSourceGIFFrameDuration(source, index)
      frameDurations.append(frameDuration)
      totalDuration += frameDuration

      if index < framesToPreload {
        let frameImageRef = CGImageSourceCreateImageAtIndex(self.imageSource, UInt(index), nil)
        let frame = UIImage(CGImage: frameImageRef, scale: 0.0, orientation: UIImageOrientation.Up)
        frames.append(frame)
      } else {
        frames.append(nil)
      }
    }
  }

  func frameAtIndex(index: Int) -> UIImage? {
    if Int(index) >= self.frames.count { return nil }

    var image: UIImage? = self.frames[Int(index)]
    updatePreloadedFramesAtIndex(index)

    return image
  }

  private func updatePreloadedFramesAtIndex(index: Int) {
    if frames.count <= framesToPreload { return }

    if index != 0 {
      frames[index] = nil
    }

    for internalIndex in (index + 1)...(index + framesToPreload) {
      let adjustedIndex = internalIndex % frames.count

      if frames[adjustedIndex] == nil {
        dispatch_async(preloadFrameQueue) {
          let frameImageRef = CGImageSourceCreateImageAtIndex(self.imageSource, UInt(adjustedIndex), nil)
          self.frames[adjustedIndex] = UIImage(CGImage: frameImageRef)
        }
      }
    }
  }

  func updateCurrentFrame() {
    if !isAnimated { return }

    timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
    var frameDuration = frameDurations[currentFrameIndex]

    while timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
      currentFrameIndex++

      if currentFrameIndex >= frames.count {
        currentFrameIndex = 0
      }

      delegate?.layer.setNeedsDisplay()
    }
  }

  // MARK: - Animation
  func pauseAnimation() {
    displayLink.paused = true
  }

  func resumeAnimation() {
    displayLink.paused = false
  }

  func isAnimating() -> Bool {
    return !displayLink.paused
  }
}
