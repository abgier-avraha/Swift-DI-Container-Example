// TODO: init argument reflection and automatic injection?
public class SharedContainer
{
  static let container = DependencyInjectionContainer()
}

public class DependencyInjectionContainer
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

@propertyWrapper
public class Injected<T: AnyObject> {

  private var container: DependencyInjectionContainer

  public init()
  {
    self.container = SharedContainer.container
  }

  public init(customContainer: DependencyInjectionContainer) {
    self.container = customContainer
  }

  /// A computed accessor for the dependency. Will retain the initialized instance.
  public var wrappedValue: T {
      let object = try! container.provide(forType: T.self)
      return object
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