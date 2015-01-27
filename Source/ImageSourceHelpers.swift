import UIKit
import ImageIO
import MobileCoreServices
import Runes

internal typealias GIFProperties = [String : Double]
private let defaultDuration: Double = 0

func CGImageSourceGIFFrameDuration(imageSource: CGImageSource, index: Int) -> NSTimeInterval {
  if !imageSource.isAnimatedGIF { return 0.0 }

  let duration = imageSource.GIFPropertiesAtIndex(UInt(index))
    >>- durationFromGIFProperties
    >>- capDuration

  return duration ?? defaultDuration
}

private func capDuration(duration: Double) -> Double? {
  if duration < 0 { return .None }
  let threshold = 0.02 - Double(FLT_EPSILON)
  let cappedDuration = duration < threshold ? 0.1 : duration
  return cappedDuration
}

private func durationFromGIFProperties(properties: GIFProperties) -> Double? {
  let unclampedDelayTime = properties[String(kCGImagePropertyGIFUnclampedDelayTime)]
  let delayTime = properties[String(kCGImagePropertyGIFDelayTime)]

  return duration <^> unclampedDelayTime <*> delayTime
}

private func duration(unclampedDelayTime: Double)(delayTime: Double) -> Double {
  let delayArray = [unclampedDelayTime, delayTime]
  return delayArray.filter(isPositive).first ?? defaultDuration
}

private func isPositive(value: Double) -> Bool {
  return value >= 0
}

extension CGImageSourceRef {
  var isAnimatedGIF: Bool {
    let isTypeGIF = UTTypeConformsTo(CGImageSourceGetType(self), kUTTypeGIF)
    let imageCount = CGImageSourceGetCount(self)
    return isTypeGIF != 0 && imageCount > 1
  }

  func GIFPropertiesAtIndex(index: UInt) -> GIFProperties? {
    if !isAnimatedGIF { return .None }

    let imageProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as Dictionary
    return imageProperties[String(kCGImagePropertyGIFDictionary)] as? GIFProperties
  }
}
