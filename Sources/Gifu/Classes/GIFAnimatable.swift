import Foundation
import UIKit

/// The protocol that view classes need to conform to to enable animated GIF support.
@MainActor
public protocol GIFAnimatable: AnyObject, Sendable {
  /// Responsible for managing the animation frames.
  var animator: Animator? { get set }

  /// Notifies the instance that it needs display.
  var layer: CALayer { get }

  /// View frame used for resizing the frames.
  var frame: CGRect { get set }

  /// Content mode used for resizing the frames.
  var contentMode: UIView.ContentMode { get set }
}

/// A single-property protocol that animatable classes can optionally conform to.
public protocol ImageContainer: AnyObject {
  /// Used for displaying the animation frames.
  @MainActor var image: UIImage? { get set }
}

extension GIFAnimatable where Self: ImageContainer {
  /// Returns the intrinsic content size based on the size of the image.
  public var intrinsicContentSize: CGSize {
    return image?.size ?? CGSize.zero
  }
}

extension GIFAnimatable {
  /// Total duration of one animation loop
  public var gifLoopDuration: TimeInterval {
    return animator?.loopDuration ?? 0
  }

  /// Returns the active frame if available.
  public var activeFrame: UIImage? {
    return animator?.activeFrame()
  }

  /// Total frame count of the GIF.
  public var frameCount: Int {
    return animator?.frameCount ?? 0
  }

  /// Introspect whether the instance is animating.
  public var isAnimatingGIF: Bool {
    return animator?.isAnimating ?? false
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter preparationBlock: Callback for when preparation is done
  /// - parameter animationBlock: Callback for when all the loops of the animation are done (never called for infinite loops)
  /// - parameter loopBlock: Callback for when a loop is done (at the end of each loop)
  public func animate(
    withGIFNamed imageName: String,
    loopCount: Int = 0,
    preparationBlock: (@Sendable () -> Void)? = nil,
    animationBlock: (@Sendable () -> Void)? = nil,
    loopBlock: (@Sendable () -> Void)? = nil
  ) {
    animator?.animate(
      withGIFNamed: imageName,
      size: frame.size,
      contentMode: contentMode,
      loopCount: loopCount,
      preparationBlock: preparationBlock,
      animationBlock: animationBlock,
      loopBlock: loopBlock
    )
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter preparationBlock: Callback for when preparation is done
  /// - parameter animationBlock: Callback for when all the loops of the animation are done (never called for infinite loops)
  /// - parameter loopBlock: Callback for when a loop is done (at the end of each loop)
  public func animate(
    withGIFData imageData: Data,
    loopCount: Int = 0,
    preparationBlock: (@Sendable () -> Void)? = nil,
    animationBlock: (@Sendable () -> Void)? = nil,
    loopBlock: (@Sendable () -> Void)? = nil
  ) {
    animator?.animate(
      withGIFData: imageData,
      size: frame.size,
      contentMode: contentMode,
      loopCount: loopCount,
      preparationBlock: preparationBlock,
      animationBlock: animationBlock,
      loopBlock: loopBlock
    )
  }

  /// Prepare for animation and start animating immediately.
  ///
  /// - parameter imageURL: GIF image url.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter preparationBlock: Callback for when preparation is done
  /// - parameter animationBlock: Callback for when all the loops of the animation are done (never called for infinite loops)
  /// - parameter loopBlock: Callback for when a loop is done (at the end of each loop)
  public func animate(
    withGIFURL imageURL: URL,
    loopCount: Int = 0,
    preparationBlock: (@Sendable () -> Void)? = nil,
    animationBlock: (@Sendable () -> Void)? = nil,
    loopBlock: (@Sendable () -> Void)? = nil
  ) {
    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        await MainActor.run {
          self.animate(
            withGIFData: data,
            loopCount: loopCount,
            preparationBlock: preparationBlock,
            animationBlock: animationBlock,
            loopBlock: loopBlock
          )
        }
      } catch {
        print("Error downloading gif:", error.localizedDescription, "at url:", imageURL.absoluteString)
      }
    }
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageName: The file name of the GIF in the main bundle.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Callback for when preparation is done
  public func prepareForAnimation(
    withGIFNamed imageName: String,
    loopCount: Int = 0,
    completionHandler: (@Sendable () -> Void)? = nil
  ) {
    animator?.prepareForAnimation(
      withGIFNamed: imageName,
      size: frame.size,
      contentMode: contentMode,
      loopCount: loopCount,
      completionHandler: completionHandler
    )
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageData: GIF image data.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Callback for when preparation is done
  public func prepareForAnimation(
    withGIFData imageData: Data,
    loopCount: Int = 0,
    completionHandler: (@Sendable () -> Void)? = nil
  ) {
    if let imageContainer = self as? (any ImageContainer) {
      MainActor.assumeIsolated {
        imageContainer.image = UIImage(data: imageData)
      }
    }

    animator?.prepareForAnimation(
      withGIFData: imageData,
      size: frame.size,
      contentMode: contentMode,
      loopCount: loopCount,
      completionHandler: completionHandler
    )
  }

  /// Prepares the animator instance for animation.
  ///
  /// - parameter imageURL: GIF image url.
  /// - parameter loopCount: Desired number of loops, <= 0 for infinite loop.
  /// - parameter completionHandler: Callback for when preparation is done
  public func prepareForAnimation(
    withGIFURL imageURL: URL,
    loopCount: Int = 0,
    completionHandler: (@Sendable () -> Void)? = nil
  ) {
    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        await MainActor.run {
          self.prepareForAnimation(
            withGIFData: data,
            loopCount: loopCount,
            completionHandler: completionHandler
          )
        }
      } catch {
        print("Error downloading gif:", error.localizedDescription, "at url:", imageURL.absoluteString)
      }
    }
  }

  /// Stop animating and free up GIF data from memory.
  public func prepareForReuse() {
    animator?.prepareForReuse()
  }

  /// Start animating GIF.
  public func startAnimatingGIF() {
    animator?.startAnimating()
  }

  /// Stop animating GIF.
  public func stopAnimatingGIF() {
    animator?.stopAnimating()
  }

  /// Whether the frame images should be resized or not. The default is `false`, which means that the frame images retain their original size.
  ///
  /// - parameter resize: Boolean value indicating whether individual frames should be resized.
  public func setShouldResizeFrames(_ resize: Bool) {
    animator?.shouldResizeFrames = resize
  }

  /// Sets the number of frames that should be buffered. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
  ///
  /// - parameter frames: The number of frames to buffer.
  @available(*, deprecated, message: "Use setFrameBufferSize instead.")
  public func setFrameBufferCount(_ frames: Int) {
    setFrameBufferSize(frames)
  }

  /// Sets the number of frames that should be buffered. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
  ///
  /// - parameter frames: The number of frames to buffer.
  public func setFrameBufferSize(_ frames: Int) {
    animator?.frameBufferSize = frames
  }

  /// Updates the image with a new frame if necessary.
  public func updateImageIfNeeded() {
    if let imageContainer = self as? (any ImageContainer) {
      let currentImage = imageContainer.image
      let newImage = activeFrame ?? currentImage
      imageContainer.image = newImage
    } else {
      layer.contents = activeFrame?.cgImage
    }
  }
}

extension GIFAnimatable {
  /// Calls setNeedsDisplay on the layer whenever the animator has a new frame. Should *not* be called directly.
  func animatorHasNewFrame() {
    layer.setNeedsDisplay()
  }
}
