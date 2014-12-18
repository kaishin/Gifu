extension UIImage {
  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    self.drawInRect(CGRectMake(0, 0, size.width, size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
