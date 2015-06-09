import ImageIO
import MobileCoreServices
import UIKit

typealias GIFProperties = [String : Double]
let defaultDuration: Double = 0

/// Retruns the duration of a frame at a specific index using an image source (an `CGImageSource` instance).
///
/// - returns: A frame duration.
func CGImageSourceGIFFrameDuration(imageSource: CGImageSource, index: Int) -> NSTimeInterval {
  if !imageSource.isAnimatedGIF { return 0.0 }

  let duration = imageSource.GIFPropertiesAtIndex(index)
    >>- durationFromGIFProperties
    >>- capDuration

  return duration ?? defaultDuration
}

/// Ensures that a duration is never smaller than a threshold value.
///
/// - returns: A capped frame duration.
func capDuration(duration: Double) -> Double? {
  if duration < 0 { return .None }
  let threshold = 0.02 - Double(FLT_EPSILON)
  let cappedDuration = duration < threshold ? 0.1 : duration
  return cappedDuration
}

/// Returns a frame duration from a `GIFProperties` dictionary.
///
/// - returns: A frame duration.
func durationFromGIFProperties(properties: GIFProperties) -> Double? {
  let unclampedDelayTime = properties[String(kCGImagePropertyGIFUnclampedDelayTime)]
  let delayTime = properties[String(kCGImagePropertyGIFDelayTime)]

  return duration <^> unclampedDelayTime <*> delayTime
}

/// Calculates frame duration based on both clamped and unclamped times.
///
/// - returns: A frame duration.
func duration(unclampedDelayTime: Double)(delayTime: Double) -> Double {
  let delayArray = [unclampedDelayTime, delayTime]
  return delayArray.filter(isPositive).first ?? defaultDuration
}

/// Checks if a `Double` value is positive.
///
/// - returns: A boolean value that is `true` if the tested value is positive.
func isPositive(value: Double) -> Bool {
  return value >= 0
}

/// An extension of `CGImageSourceRef` that add GIF introspection and easier property retrieval.
extension CGImageSourceRef {
  /// Returns whether the image source contains an animated GIF.
  ///
  /// - returns: A boolean value that is `true` if the image source contains animated GIF data.
  var isAnimatedGIF: Bool {
    let isTypeGIF = UTTypeConformsTo(CGImageSourceGetType(self) ?? "", kUTTypeGIF)
    let imageCount = CGImageSourceGetCount(self)
    return isTypeGIF != false && imageCount > 1
  }

  /// Returns the GIF properties at a specific index.
  ///
  /// - parameter index: The index of the GIF properties to retrieve.
  /// - returns: A dictionary containing the GIF properties at the passed in index.
  func GIFPropertiesAtIndex(index: Int) -> GIFProperties? {
    let imageProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as Dictionary?
    return imageProperties?[String(kCGImagePropertyGIFDictionary)] as? GIFProperties
  }
}
