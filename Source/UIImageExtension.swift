/// A `UIImage` extension that makes it easier to resize the image and inspect its size.

extension UIImage {
  /// Resizes an image instance.
  ///
  /// :param: size The new size of the image.
  /// :returns: A new resized image instance.
  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    self.drawInRect(CGRectMake(0, 0, size.width, size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  /// Returns a new `UIImage` instance using raw image data and a size.
  ///
  /// :param: data Raw image data.
  /// :param: size The size to be used to resize the new image instance.
  /// :returns: A new image instance from the passed in data.
  class func imageWithData(data: NSData, size: CGSize) -> UIImage? {
    return UIImage(data: data)?.resize(size)
  }

  /// Returns an image size from raw image data.
  ///
  /// :param: data Raw image data.
  /// :returns: The size of the image contained in the data.
  class func sizeForImageData(data: NSData) -> CGSize? {
    return UIImage(data: data)?.size
  }
}
