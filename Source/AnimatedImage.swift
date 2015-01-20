import UIKit
import ImageIO
import Runes

public class AnimatedImage: UIImage {
  // MARK: - Constants
  let maxTimeStep = 1.0

  // MARK: - Public Properties
  var delegate: UIImageView?
  var animatedFrames = [AnimatedFrame]()
  var totalDuration: NSTimeInterval = 0.0

  override public var size: CGSize {
    return frameAtIndex(0)?.size ?? CGSizeZero
  }

  // MARK: - Private Properties
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "updateCurrentFrame")
  private var currentFrameIndex = 0
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0

  // MARK: - Computed Properties
  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  private var isAnimated: Bool {
    return totalDuration != 0.0
  }

  // MARK: - Initializers
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  public override convenience init(data: NSData) {
    self.init(data: data, size: CGSizeZero)
  }

  required public init(data: NSData, size: CGSize) {
    super.init()

    let imageSource = CGImageSourceCreateWithData(data, nil)
    attachDisplayLink()
    curry(prepareFrames) <^> imageSource <*> size
    pauseAnimation()
  }

  // MARK: - Factories
  public class func animatedImageWithName(name: String) -> AnimatedImage? {
    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(name)
    return animatedImageWithData <^> NSData(contentsOfFile: path)
  }

  public class func animatedImageWithData(data: NSData) -> AnimatedImage {
    let size = UIImage.sizeForImageData(data) ?? CGSizeZero
    return self(data: data, size: size)
  }

  public class func animatedImageWithName(name: String, size: CGSize) -> AnimatedImage? {
    let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(name)
    return curry(animatedImageWithData) <^> NSData(contentsOfFile: path) <*> size
  }

  public class func animatedImageWithData(data: NSData, size: CGSize) -> AnimatedImage {
    return self(data: data, size: size)
  }

  // MARK: - Display Link Helpers
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }

  // MARK: - Frame Methods
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

  func frameAtIndex(index: Int) -> UIImage? {
    if index >= animatedFrames.count { return .None }
    return animatedFrames[index].image
  }

  func updateCurrentFrame() {
    if !isAnimated { return }

    timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
    var frameDuration = animatedFrames[currentFrameIndex].duration

    if timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
      currentFrameIndex = ++currentFrameIndex % animatedFrames.count
      delegate?.layer.setNeedsDisplay()
    }
  }

  // MARK: - Animation
  func pauseAnimation() {
    displayLink.paused = true
  }

  func resumeAnimation() {
    if isAnimated {
      displayLink.paused = false
    }
  }

  func isAnimating() -> Bool {
    return !displayLink.paused
  }
}
