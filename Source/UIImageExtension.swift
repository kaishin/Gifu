/// A `UIImage` extension that makes it easier to resize the image and inspect its size.

extension UIImage {
  /// Resizes an image instance.
  ///
  /// :param: size The new size of the image.
  /// :returns: A new resized image instance.
  func resize(size: CGSize) -> UIImage {
    let newSize = self.size.sizeConstrainedBySize(size)
    UIGraphicsBeginImageContext(newSize)
    self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
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

private extension CGSize {
  /// Finds a new size constrained by a size keeping the aspect ratio.
  ///
  /// :param: size The contraining size.
  /// :returns: size A new size that fits inside the contraining size with the same aspect ratio.
  func sizeConstrainedBySize(size: CGSize) -> CGSize {
    if height == 0 { return size }

    let aspectRatio = width / height
    let aspectWidth = round(aspectRatio * size.height)
    let aspectHeight = round(size.width / aspectRatio)

    if aspectWidth > size.width {
      return CGSize(width: size.width, height: aspectHeight)
    } else {
      return CGSize(width: aspectWidth, height: size.height)
    }
  }
}
