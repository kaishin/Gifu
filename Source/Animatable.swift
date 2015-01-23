/// Protocol that requires its members to have a `layer` and a `frame` property.
/// Classes confirming to this protocol can serve as a delegate to `Animator`.
protocol Animatable {
  var layer: CALayer { get }
  var frame: CGRect { get }
}
