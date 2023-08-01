// The Swift Programming Language
// https://docs.swift.org/swift-book

// TODO: init argument reflection and automatic injection?
// TODO: property wrapper dependency injection (has optional container arg, uses default container by default)
class SharedContainer
{
  static let container = DependencyInjectionContainer()
}

class DependencyInjectionContainer
{
  private var singletonMap: [String: AnyObject] = [:]

  func inject<T: AnyObject>(use: T, forType: T.Type)
  {
    self.singletonMap[forType] = use
  }

  func provide<T: AnyObject>(forType: T.Type) throws -> T
  {
    let instance = self.singletonMap[forType]
    
    guard let unwrapped = instance else {
      throw DependencyInjectionError.SERVICE_NOT_INJECTED
    }

    return unwrapped as! T
  }
}

enum DependencyInjectionError: Error {
  case SERVICE_NOT_INJECTED
}

// Conerts .self class references to strings for use as keys
extension Dictionary where Key : LosslessStringConvertible
{
  subscript(index: Any.Type) -> Value?
   {
      get
      {
         return self[String(describing: index) as! Key]
      }
      set(newValue)
      {
         self[String(describing: index) as! Key] = newValue
      }
   }
}