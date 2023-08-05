// TODO: init argument reflection and automatic injection?
public class DependencyInjectionContainer
{
  public var singletonMap: [String: AnyObject] = [:]
  public var transientMap: [String: () -> AnyObject] = [:]
  public var scopedMap: [String: () -> AnyObject] = [:]

  func createScope() -> ServiceScope
  {
    return ServiceScope(self)
  }

  func injectSingleton<T: AnyObject>(_ object: T)
  {
    self.singletonMap[T.self] = object
  }

  func injectTransient<T: AnyObject>(_ objectBuilder: @escaping () -> T)
  {
    self.transientMap[T.self] = objectBuilder
  }
  func injectScoped<T: AnyObject>(_ objectBuilder: @escaping () -> T)
  {
    self.scopedMap[T.self] = objectBuilder
  }

  func remove<T>(_ forType: T.Type)
  {
    self.singletonMap.removeValue(forKey: String(describing: forType))
    self.transientMap.removeValue(forKey: String(describing: forType))
    self.scopedMap.removeValue(forKey: String(describing: forType))
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