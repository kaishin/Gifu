import ImageIO
import Testing
import UIKit

@testable import Gifu

private let imageData = testImageDataNamed("mugen.gif")
private let staticImage = UIImage(data: imageData)!
private let preloadFrameCount = 20

class DummyAnimatable: GIFAnimatable {
  init() {}
  var animator: Animator? = nil
  var image: UIImage? = nil
  var layer = CALayer()
  var frame: CGRect = .zero
  var contentMode: UIView.ContentMode = .scaleToFill
  func animatorHasNewFrame() {}
}

@MainActor
@Suite("Gifu Tests")
struct GifuTests {
  let delegate = DummyAnimatable()
  let originalFrameCount = 44

  func createAnimator() -> Animator {
    let animator = Animator(withDelegate: delegate)
    animator.prepareForAnimation(
      withGIFData: imageData, size: staticImage.size, contentMode: .scaleToFill)
    return animator
  }

  @Test func isAnimatable() {
    let animator = createAnimator()
    #expect(animator.frameStore != nil)
    guard let store = animator.frameStore else { return }
    #expect(store.isAnimatable)
  }

  @Test func currentFrame() {
    let animator = createAnimator()
    #expect(animator.frameStore != nil)
    guard let store = animator.frameStore else { return }
    #expect(store.currentFrameIndex == 0)
  }

  @Test func framePreload() async {
    let animator = createAnimator()
    #expect(animator.frameStore != nil)
    guard let store = animator.frameStore else { return }

    await withCheckedContinuation { continuation in
      store.prepareFrames { [originalFrameCount] in
        let animatedFrameCount = store.animatedFrames.count
        #expect(animatedFrameCount == originalFrameCount)
        #expect(store.frame(at: preloadFrameCount - 1) != nil)
        #expect(store.frame(at: preloadFrameCount + 1)?.images == nil)
        #expect(store.currentFrameIndex == 0)

        store.shouldChangeFrame(with: 1.0) { hasNewFrame in
          #expect(hasNewFrame)
          #expect(store.currentFrameIndex == 1)
          continuation.resume()
        }
      }
    }
  }

  @Test func frameInfo() async {
    let animator = createAnimator()
    #expect(animator.frameStore != nil)
    guard let store = animator.frameStore else { return }

    await withCheckedContinuation { continuation in
      store.prepareFrames {
        continuation.resume()
      }
    }
    
    let frameDuration = store.frame(at: 5)?.duration ?? 0
    #expect(abs(frameDuration - 0.05) < 0.00001)
    #expect(frameDuration == 2)

    let imageSize = store.frame(at: 5)?.size ?? CGSize.zero
    #expect(imageSize == staticImage.size)
  }

  @Test func finishedStates() async {
    let animator = Animator(withDelegate: delegate)
    animator.prepareForAnimation(
      withGIFData: imageData, size: staticImage.size, contentMode: .scaleToFill, loopCount: 2)

    #expect(animator.frameStore != nil)
    guard let store = animator.frameStore else { return }

    await withCheckedContinuation { continuation in
      store.prepareFrames {
        let animatedFrameCount = store.animatedFrames.count
        #expect(store.currentFrameIndex == 0)

        // Animate through all the frames (first loop)
        for frame in 1..<animatedFrameCount {
          #expect(!store.isLoopFinished)
          #expect(!store.isFinished)
          store.shouldChangeFrame(with: 1.0) { hasNewFrame in
            #expect(hasNewFrame)
            #expect(store.currentFrameIndex == frame)
          }
        }

        #expect(store.isLoopFinished, "First loop should be finished")
        #expect(!store.isFinished, "Animation should not be finished yet")

        store.shouldChangeFrame(with: 1.0) { hasNewFrame in
          #expect(hasNewFrame)
        }

        #expect(store.currentFrameIndex == 0)

        // Animate through all the frames (second loop)
        for frame in 1..<animatedFrameCount {
          #expect(!store.isLoopFinished)
          #expect(!store.isFinished)
          store.shouldChangeFrame(with: 1.0) { hasNewFrame in
            #expect(hasNewFrame)
            #expect(store.currentFrameIndex == frame)
          }
        }

        #expect(store.isLoopFinished, "Second loop should be finished")
        #expect(store.isFinished, "Animation should be finished (loopCount: 2)")

        continuation.resume()
      }
    }
  }
}

private func testImageDataNamed(_ name: String) -> Data {
  let testBundle = Bundle.module
  let imagePath = testBundle.bundleURL.appendingPathComponent("Images").appendingPathComponent(name)
  return (try! Data(contentsOf: imagePath))
}
