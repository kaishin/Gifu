/// One of my favorite indian spices.
func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
  return { a in { b in f(a, b) } }
}

// MARK: - Optional
func <^> <T, U>(@noescape f: T -> U, a: T?) -> U? {
  return a.map(f)
}
func <*> <T, U>(f: (T -> U)?, a: T?) -> U? {
  return a.apply(f)
}

func >>- <T, U>(a: T?, @noescape f: T -> U?) -> U? {
  return a.flatMap(f)
}

func pure<T>(a: T) -> T? {
  return .Some(a)
}

extension Optional {
  func apply<U>(f: (Wrapped -> U)?) -> U? {
    return f.flatMap { self.map($0) }
  }
}

// MARK: - Array
public func <^> <T, U>(f: T -> U, a: [T]) -> [U] {
  return a.map(f)
}

public func <*> <T, U>(fs: [T -> U], a: [T]) -> [U] {
  return a.apply(fs)
}

public func >>- <T, U>(a: [T], f: T -> [U]) -> [U] {
  return a.flatMap(f)
}

public func -<< <T, U>(f: T -> [U], a: [T]) -> [U] {
  return a.flatMap(f)
}

public func pure<T>(a: T) -> [T] {
  return [a]
}

public extension Array {
  func apply<U>(fs: [Element -> U]) -> [U] {
    return fs.flatMap { self.map($0) }
  }
}
