/// A `UIImage` extension that makes it easier to resize the image and inspect its size.

extension UIImage {
  /// Resizes an image instance.
  ///
  /// - parameter size: The new size of the image.
  /// - returns: A new resized image instance.
  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    self.drawInRect(CGRect(origin: CGPointZero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage ?? self
  }

  /// Resizes an image instance to fit inside a constraining size while keeping the aspect ratio.
  ///
  /// - parameter size: The constraining size of the image.
  /// - returns: A new resized image instance.
  func resizeAspectFit(size: CGSize) -> UIImage {
    let newSize = self.size.sizeConstrainedBySize(size)
    return resize(newSize)
  }

  /// Resizes an image instance to fill a constraining size while keeping the aspect ratio.
  ///
  /// - parameter size: The constraining size of the image.
  /// - returns: A new resized image instance.
  func resizeAspectFill(size: CGSize) -> UIImage {
    let newSize = self.size.sizeFillingSize(size)
    return resize(newSize)
  }

  /// Returns a new `UIImage` instance using raw image data and a size.
  ///
  /// - parameter data: Raw image data.
  /// - parameter size: The size to be used to resize the new image instance.
  /// - returns: A new image instance from the passed in data.
  class func imageWithData(data: NSData, size: CGSize) -> UIImage? {
    return UIImage(data: data)?.resize(size)
  }

  /// Returns an image size from raw image data.
  ///
  /// - parameter data: Raw image data.
  /// - returns: The size of the image contained in the data.
  class func sizeForImageData(data: NSData) -> CGSize? {
    return UIImage(data: data)?.size
  }
}
