// TODO: init argument reflection and automatic injection?
public class DependencyInjectionContainer
{
  private var singletonMap: [String: AnyObject] = [:]
  private var transientMap: [String: () -> AnyObject] = [:]

  func injectSingleton<T: AnyObject>(_ object: T)
  {
    self.singletonMap[T.self] = object
  }

  func injectTransient<T: AnyObject>(_ objectBuilder: @escaping () -> T)
  {
    self.transientMap[T.self] = objectBuilder
  }
  
  func provide<T: AnyObject>(forType: T.Type) throws -> T
  {
    // Check for singleton deps
    let instance = self.singletonMap[forType]
    guard let unwrappedInstance = instance else {
      
      // Check for transient deps
      let instanceBuilder = self.transientMap[forType]
      guard let unwrappedInstanceBuilder = instanceBuilder else {

        // No dep found
        throw DependencyInjectionError.SERVICE_NOT_INJECTED
      }

      return unwrappedInstanceBuilder() as! T
    }

    return unwrappedInstance as! T
  }

  func provide<T: AnyObject>() throws -> T
  {
    return try self.provide(forType: T.self)
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