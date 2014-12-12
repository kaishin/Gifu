infix operator >>- { associativity left precedence 150 }
infix operator <^> { associativity left precedence 150 }
infix operator <*> { associativity left precedence 150 }

func >>-<A, B>(a: A?, f: A -> B?) -> B? {
  switch a {
  case let .Some(x): return f(x)
  case .None: return .None
  }
}

func <^><A, B>(f: A -> B, a: A?) -> B? {
  switch a {
  case let .Some(x): return f(x)
  case .None: return .None
  }
}

func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
  switch f {
  case let .Some(fx): return fx <^> a
  case .None: return .None
  }
}

func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
  return { a in { b in f(a, b) } }
}
