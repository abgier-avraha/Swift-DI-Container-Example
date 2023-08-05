@propertyWrapper
public class Provide<T: AnyObject> {

  private var cachedObject: T?
  private var scope: ServiceScope

  public init()
  {
    self.scope = DefaultScope.scope
  }

  public init(_ scope: ServiceScope) {
    self.scope = scope
  }

  /// A computed accessor for the dependency.
  // Will retain the initialized instance.
  // This will prevent transient deps from being reconstructed accessed
  public var wrappedValue: T {
    guard let unwrappedCachedObject = self.cachedObject else {
      let object = try! self.scope.provide(T.self)
      self.cachedObject = object
      return object
    }

    return unwrappedCachedObject
  }
}