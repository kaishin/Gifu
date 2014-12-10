import UIKit
import ImageIO
import MobileCoreServices

func CGImageSourceContainsAnimatedGIF(imageSource: CGImageSource) -> Bool {
  let isTypeGIF = UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF)
  let imageCount = CGImageSourceGetCount(imageSource)
  return isTypeGIF != 0 && imageCount > 1
}

func CGImageSourceGIFFrameDuration(imageSource: CGImageSource, index: Int) -> NSTimeInterval {
  let containsAnimatedGIF = CGImageSourceContainsAnimatedGIF(imageSource)
  if !containsAnimatedGIF { return 0.0 }

  var duration = 0.0
  let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, UInt(index), nil) as NSDictionary
  let GIFProperties: NSDictionary? = imageProperties.objectForKey(kCGImagePropertyGIFDictionary) as? NSDictionary

  if let properties = GIFProperties {
    duration = properties.valueForKey(kCGImagePropertyGIFUnclampedDelayTime) as Double

    if duration <= 0 {
      duration = properties.valueForKey(kCGImagePropertyGIFDelayTime) as Double
    }
  }

  let threshold = 0.02 - Double(FLT_EPSILON)

  if duration > 0 && duration < threshold {
    duration = 0.1
  }

  return duration
}
