import XCTest
import ImageIO
@testable import Gifu

private let imageData = testImageDataNamed("mugen.gif")
private let staticImage = UIImage(data: imageData!)

class GifuTests: XCTestCase {
  var animator: Animator?
  var originalFrameCount: Int?
  var preloadedFrameCount: Int?

  override func setUp() {
    super.setUp()
    animator = Animator(data: imageData!, size: CGSizeZero, contentMode: .ScaleToFill, framePreloadCount: 20)
    animator!.prepareFrames()
    originalFrameCount = Int(CGImageSourceGetCount(animator!.imageSource))
    preloadedFrameCount = animator!.animatedFrames.count
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testIsAnimatable() {
    XCTAssertTrue(animator!.isAnimatable)
  }

  func testFramePreload() {
    XCTAssertLessThanOrEqual(preloadedFrameCount!, originalFrameCount!)
  }

  func testFrameAtIndex() {
    XCTAssertNotNil(animator!.frameAtIndex(preloadedFrameCount! - 1))
  }

  func testFrameDurationPrecision() {
    let image = animator!.frameAtIndex(5)
    XCTAssertTrue((image!.duration - 0.05) < 0.00001)
  }

  func testFrameSize() {
    let image = animator!.frameAtIndex(5)
    XCTAssertEqual(image!.size, staticImage!.size)
  }

  func testPrepareFramesPerformance() {
    let tempAnimator = Animator(data: imageData!, size: CGSizeZero, contentMode: .ScaleToFill, framePreloadCount: 50)

    self.measureBlock() {
      tempAnimator.prepareFrames()
    }
  }
}

private func testImageDataNamed(name: String) -> NSData? {
  let testBundle = NSBundle(forClass: GifuTests.self)
  let imagePath = testBundle.bundleURL.URLByAppendingPathComponent(name)
  return NSData(contentsOfURL: imagePath)
}
