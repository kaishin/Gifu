import UIKit
import ImageIO

public class AnimatedView: UIView {
  private var frames: [AnimatedFrame] = []
  private var currentFrameIndex = 0
  private var displayLink: CADisplayLink?
  private var timeSinceLastUpdate: NSTimeInterval = 0

  public var isAnimated: Bool {
    return frames.count > 1
  }

  public var isAnimating: Bool {
    return !(displayLink?.paused ?? true)
  }

  public func setAnimatedFrames(frames: [AnimatedFrame]) {
    self.frames = frames
    initialize()
    attachDisplayLink()
    pauseAnimation()
  }

  private func initialize() {
    layer.contents = frames.first?.image?.CGImage
    currentFrameIndex = 0
    timeSinceLastUpdate = 0
  }

  func updateLayer() {
    let frame = frames[currentFrameIndex]
    timeSinceLastUpdate += displayLink?.duration ?? 0

    if timeSinceLastUpdate >= frame.duration {
      timeSinceLastUpdate -= frame.duration
      currentFrameIndex = ++currentFrameIndex % frames.count
      layer.contents = frames[currentFrameIndex].image?.CGImage
    }
  }

  private func attachDisplayLink() {
    if displayLink != .None { return }
    displayLink = CADisplayLink(target: self, selector: "updateLayer")
    displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }

  deinit {
    displayLink?.invalidate()
  }

  public func pauseAnimation() {
    displayLink?.paused = true
  }

  public func resumeAnimation() {
    if isAnimated {
      displayLink?.paused = false
    }
  }
}
