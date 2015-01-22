import UIKit
import ImageIO
import Runes

class Animator: NSObject {
  let maxTimeStep = 1.0
  var animatedFrames = [AnimatedFrame]()
  var totalDuration: NSTimeInterval = 0.0
  let delegate: Animatable
  private var currentFrameIndex = 0
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "updateCurrentFrame")

  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  var isAnimating: Bool {
    return !displayLink.paused
  }

  required init(data: NSData, delegate: Animatable) {
    let imageSource = CGImageSourceCreateWithData(data, nil)
    self.delegate = delegate
    super.init()
    attachDisplayLink()
    curry(prepareFrames) <^> imageSource <*> delegate.frame.size
    pauseAnimation()
  }

  // MARK: - Frames
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
  func pauseAnimation() {
    displayLink.paused = true
  }

  func resumeAnimation() {
    if totalDuration > 0 {
      displayLink.paused = false
    }
  }

  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
}
