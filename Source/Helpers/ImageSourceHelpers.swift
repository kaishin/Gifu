import ImageIO
import MobileCoreServices
import UIKit

typealias GIFProperties = [String: Double]
let defaultDuration: Double = 0

/// Retruns the duration of a frame at a specific index using an image source (an `CGImageSource` instance).
///
/// - returns: A frame duration.
func CGImageFrameDuration(with imageSource: CGImageSource, atIndex index: Int) -> TimeInterval {
  if !imageSource.isAnimatedGIF { return 0.0 }

  guard let GIFProperties = imageSource.properties(at: index),
    let duration = frameDuration(with: GIFProperties),
    let cappedDuration = capDuration(with: duration)
    else { return defaultDuration }

  return cappedDuration
}

/// Ensures that a duration is never smaller than a threshold value.
///
/// - returns: A capped frame duration.
func capDuration(with duration: Double) -> Double? {
  if duration < 0 { return nil }
  let threshold = 0.02 - Double.ulpOfOne
  let cappedDuration = duration < threshold ? 0.1 : duration
  return cappedDuration
}

/// Returns a frame duration from a `GIFProperties` dictionary.
///
/// - returns: A frame duration.
func frameDuration(with properties: GIFProperties) -> Double? {
  guard let unclampedDelayTime = properties[String(kCGImagePropertyGIFUnclampedDelayTime)],
    let delayTime = properties[String(kCGImagePropertyGIFDelayTime)]
    else { return nil }

  return duration(withUnclampedTime: unclampedDelayTime, andClampedTime: delayTime)
}

/// Calculates frame duration based on both clamped and unclamped times.
///
/// - returns: A frame duration.
func duration(withUnclampedTime unclampedDelayTime: Double, andClampedTime delayTime: Double) -> Double {
  let delayArray = [unclampedDelayTime, delayTime]
  return delayArray.filter({ $0 >= 0 }).first ?? defaultDuration
}

/// An extension of `CGImageSourceRef` that adds GIF introspection and easier property retrieval.
extension CGImageSource {
  /// Returns whether the image source contains an animated GIF.
  ///
  /// - returns: A boolean value that is `true` if the image source contains animated GIF data.
  var isAnimatedGIF: Bool {
    let isTypeGIF = UTTypeConformsTo(CGImageSourceGetType(self) ?? "" as CFString, kUTTypeGIF)
    let imageCount = CGImageSourceGetCount(self)
    return isTypeGIF != false && imageCount > 1
  }

  /// Returns the GIF properties at a specific index.
  ///
  /// - parameter index: The index of the GIF properties to retrieve.
  /// - returns: A dictionary containing the GIF properties at the passed in index.
  func properties(at index: Int) -> GIFProperties? {
    guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [String: AnyObject] else { return nil }
    return imageProperties[String(kCGImagePropertyGIFDictionary)] as? GIFProperties
  }
}
