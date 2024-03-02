#if os(iOS) || os(tvOS) || os(visionOS)
/// Makes `UIImageView` conform to `ImageContainer`
import UIKit
extension UIImageView: ImageContainer {}
#endif
