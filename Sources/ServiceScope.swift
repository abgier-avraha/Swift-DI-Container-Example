public class ServiceScope {
  public var container: DependencyInjectionContainer
  private var scopedCache: [String: AnyObject] = [:]

  init(_ container: DependencyInjectionContainer) {
    self.container = container
  }

  func provide<T: AnyObject>(_ forType: T.Type) throws -> T {
    /*
      Temporarily set this ServiceScope as the current thread-local scope.
      The previous scope is saved and restored after this function completes.
      This allows @Provide to resolve dependencies from the same scope as the root provide() call.
    */
    let previous = ScopeContext.current
    ScopeContext.current = self
    defer { ScopeContext.current = previous }

    let key = String(describing: forType)

    // 1. Singleton deps
    if let instance = container.singletonMap[key] {
      return instance as! T
    }

    // 2. Scoped cache
    if let instance = scopedCache[key] {
      return instance as! T
    }

    // 3. Scoped deps (build & cache)
    if let builder = container.scopedMap[key] {
      let instance = builder() as! T
      scopedCache[key] = instance
      return instance
    }

    // 4. Transient deps (always new)
    if let builder = container.transientMap[key] {
      return builder() as! T
    }

    // 5. Nothing found
    throw DependencyInjectionError.SERVICE_NOT_INJECTED
  }

  func provide<T: AnyObject>() throws -> T {
    return try provide(T.self)
  }
}
