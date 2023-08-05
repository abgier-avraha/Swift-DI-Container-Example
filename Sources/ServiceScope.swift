public class ServiceScope
{
  public var container: DependencyInjectionContainer
  private var scopedCache: [String: AnyObject] = [:]

  init(_ container: DependencyInjectionContainer)
  {
    self.container = container
  }

  func provide<T: AnyObject>(_ forType: T.Type) throws -> T
  {
    // Check for singleton deps
    let instance = self.container.singletonMap[forType]

    guard let unwrappedInstance = instance else {
      
      // Check for transient deps
      let instanceBuilder = self.container.transientMap[forType]
      guard let unwrappedInstanceBuilder = instanceBuilder else {

        // Check for scoped cache
        let instance = self.scopedCache[forType]
        guard let unwrappedInstance = instance else {
        
          // Check for scoped deps
          let instanceBuilder = self.container.scopedMap[forType]
          guard let unwrappedInstanceBuilder = instanceBuilder else {

            // No dep found
            throw DependencyInjectionError.SERVICE_NOT_INJECTED
          }

          // Cache the scoped dep
          let scopedDep = unwrappedInstanceBuilder() as! T
          self.scopedCache[forType] = scopedDep
          return scopedDep
        }

        return unwrappedInstance as! T
      }

      return unwrappedInstanceBuilder() as! T
    }

    return unwrappedInstance as! T
  }

  func provide<T: AnyObject>() throws -> T
  {
    return try self.provide(T.self)
  }
}