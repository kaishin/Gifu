import XCTest
import ImageIO
@testable import Gifu

private let imageData = testImageDataNamed("mugen.gif")
private let staticImage = UIImage(data: imageData)!
private let preloadFrameCount = 20

class GifuTests: XCTestCase {
  var animator: Animator!
  var originalFrameCount: Int!

  override func setUp() {
    super.setUp()
    animator = Animator(data: imageData, size: CGSizeZero, contentMode: .ScaleToFill, framePreloadCount: preloadFrameCount)
    originalFrameCount = Int(CGImageSourceGetCount(animator.imageSource))
  }
  
  func testIsAnimatable() {
    XCTAssertTrue(animator.isAnimatable)
  }

  func testCurrentFrame() {
    XCTAssertEqual(animator.currentFrameIndex, 0)
    XCTAssertEqual(animator.currentFrameDuration, NSTimeInterval.infinity)
    XCTAssertNil(animator.currentFrameImage)
  }

  func testFramePreload() {
    let expectation = expectationWithDescription("frameDuration")

    animator.prepareFrames {
      let animatedFrameCount = self.animator.animatedFrames.count
      XCTAssertEqual(animatedFrameCount, self.originalFrameCount)
      XCTAssertNotNil(self.animator.frameAtIndex(preloadFrameCount - 1))
      XCTAssertNil(self.animator.frameAtIndex(preloadFrameCount + 1)?.images)
      XCTAssertEqual(self.animator.currentFrameIndex, 0)

      self.animator.shouldChangeFrame(1.0) { hasNewFrame in
        XCTAssertTrue(hasNewFrame)
        XCTAssertEqual(self.animator.currentFrameIndex, 1)
        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(1.0) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testFrameInfo() {
    let expectation = expectationWithDescription("testFrameInfoIsAccurate")

    animator.prepareFrames {
      let frameDuration = self.animator.frameAtIndex(5)?.duration ?? 0
      XCTAssertTrue((frameDuration - 0.05) < 0.00001)

      let imageSize = self.animator.frameAtIndex(5)?.size ?? CGSizeZero
      XCTAssertEqual(imageSize, staticImage.size)

      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1.0) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }
}

private func testImageDataNamed(name: String) -> NSData {
  let testBundle = NSBundle(forClass: GifuTests.self)
  let imagePath = testBundle.bundleURL.URLByAppendingPathComponent(name)
  return NSData(contentsOfURL: imagePath)!
}
