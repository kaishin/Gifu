extension UIImage {
  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    self.drawInRect(CGRectMake(0, 0, size.width, size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }

  class func imageWithData(data: NSData, size: CGSize) -> UIImage? {
    return UIImage(data: data)?.resize(size)
  }

  class func sizeForImageData(data: NSData) -> CGSize? {
    return UIImage(data: data)?.size
  }
}
