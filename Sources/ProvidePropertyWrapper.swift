@propertyWrapper
public class Provide<T: AnyObject> {

  private var cachedObject: T?
  private var container: DependencyInjectionContainer

  public init()
  {
    self.container = SharedContainer.container
  }

  public init(customContainer: DependencyInjectionContainer) {
    self.container = customContainer
  }

  /// A computed accessor for the dependency.
  // Will retain the initialized instance.
  // This will prevent transient deps from being reconstructed accessed
  public var wrappedValue: T {
    guard let unwrappedCachedObject = self.cachedObject else {
      let object = try! container.provide(forType: T.self)
      self.cachedObject = object
      return object
    }

    return unwrappedCachedObject
  }
}