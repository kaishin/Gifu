#if os(iOS) || os(tvOS)
/// Makes `UIImageView` conform to `ImageContainer`
import UIKit
extension UIImageView: ImageContainer {}
#endif
