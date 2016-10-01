import XCTest
import ImageIO
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
  var contentMode: UIViewContentMode = .scaleToFill
  func animatorHasNewFrame() {}
}

class GifuTests: XCTestCase {
  var animator: Animator!
  var originalFrameCount: Int!
  let delegate = DummyAnimatable()

  override func setUp() {
    super.setUp()
    animator = Animator(withDelegate: delegate)
    animator.prepareForAnimation(withGIFData: imageData, size: staticImage.size, contentMode: .scaleToFill)
    originalFrameCount = 44
  }
  
  func testIsAnimatable() {
    XCTAssertNotNil(animator.frameStore)
    guard let store = animator.frameStore else { return }
    XCTAssertTrue(store.isAnimatable)
  }

  func testCurrentFrame() {
    XCTAssertNotNil(animator.frameStore)
    guard let store = animator.frameStore else { return }
    XCTAssertEqual(store.currentFrameIndex, 0)
  }

  func testFramePreload() {
    XCTAssertNotNil(animator.frameStore)
    guard let store = animator.frameStore else { return }

    let expectation = self.expectation(description: "frameDuration")

    store.prepareFrames {
      let animatedFrameCount = store.animatedFrames.count
      XCTAssertEqual(animatedFrameCount, self.originalFrameCount)
      XCTAssertNotNil(store.frame(at: preloadFrameCount - 1))
      XCTAssertNil(store.frame(at: preloadFrameCount + 1)?.images)
      XCTAssertEqual(store.currentFrameIndex, 0)

      store.shouldChangeFrame(with: 1.0) { hasNewFrame in
        XCTAssertTrue(hasNewFrame)
        XCTAssertEqual(store.currentFrameIndex, 1)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 1.0) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testFrameInfo() {
    XCTAssertNotNil(animator.frameStore)
    guard let store = animator.frameStore else { return }

    let expectation = self.expectation(description: "testFrameInfoIsAccurate")

    store.prepareFrames {
      let frameDuration = store.frame(at: 5)?.duration ?? 0
      XCTAssertTrue((frameDuration - 0.05) < 0.00001)

      let imageSize = store.frame(at: 5)?.size ?? CGSize.zero
      XCTAssertEqual(imageSize, staticImage.size)

      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }
}

private func testImageDataNamed(_ name: String) -> Data {
  let testBundle = Bundle(for: GifuTests.self)
  let imagePath = testBundle.bundleURL.appendingPathComponent(name)
  return (try! Data(contentsOf: imagePath))
}
