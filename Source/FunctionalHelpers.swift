func <^> <T, U>(@noescape f: T -> U, a: T?) -> U? {
  return a.map(f)
}
func <*> <T, U>(f: (T -> U)?, a: T?) -> U? {
  return a.apply(f)
}

func >>- <T, U>(a: T?, @noescape f: T -> U?) -> U? {
  return a.flatMap(f)
}

extension Optional {
  func apply<U>(f: (Wrapped -> U)?) -> U? {
    return f.flatMap { self.map($0) }
  }
}

func pure<T>(a: T) -> [T] {
  return [a]
}
