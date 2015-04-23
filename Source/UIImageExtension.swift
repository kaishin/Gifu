/// A `UIImage` extension that makes it easier to resize the image and inspect its size.

extension UIImage {
  /// Resizes an image instance.
  ///
  /// :param: size The new size of the image.
  /// :returns: A new resized image instance.
  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    self.drawInRect(CGRect(origin: CGPointZero, size: size))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  /// Resizes an image instance to fit inside a constraining size while keeping the aspect ratio.
  ///
  /// :param: size The constraining size of the image.
  /// :returns: A new resized image instance.
  func resizeAspectFit(size: CGSize) -> UIImage {
    let newSize = self.size.sizeConstrainedBySize(size)
    return resize(newSize)
  }

  /// Resizes an image instance to fill a constraining size while keeping the aspect ratio.
  ///
  /// :param: size The constraining size of the image.
  /// :returns: A new resized image instance.
  func resizeAspectFill(size: CGSize) -> UIImage {
    let newSize = self.size.sizeFillingSize(size)
    return resize(newSize)
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
  /// Calculates the aspect ratio of the size.
  ///
  /// :returns: aspectRatio The aspect ratio of the size.
  var aspectRatio: CGFloat {
    if height == 0 { return 1 }
    return width / height
  }

  /// Finds a new size constrained by a size keeping the aspect ratio.
  ///
  /// :param: size The contraining size.
  /// :returns: size A new size that fits inside the contraining size with the same aspect ratio.
  func sizeConstrainedBySize(size: CGSize) -> CGSize {
    let aspectWidth = round(aspectRatio * size.height)
    let aspectHeight = round(size.width / aspectRatio)

    if aspectWidth > size.width {
      return CGSize(width: size.width, height: aspectHeight)
    } else {
      return CGSize(width: aspectWidth, height: size.height)
    }
  }

  /// Finds a new size filling the given size while keeping the aspect ratio.
  ///
  /// :param: size The contraining size.
  /// :returns: size A new size that fills the contraining size keeping the same aspect ratio.
  func sizeFillingSize(size: CGSize) -> CGSize {
    let aspectWidth = round(aspectRatio * size.height)
    let aspectHeight = round(size.width / aspectRatio)

    if aspectWidth > size.width {
      return CGSize(width: aspectWidth, height: size.height)
    } else {
      return CGSize(width: size.width, height: aspectHeight)
    }
  }
}
