@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testInjectAndProvide() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    let scope = container.createScope()
    let store: AnyStore<String> = try! scope.provide()
    XCTAssertEqual(store.get(), "<entity>")
  }

  func testRemovingInjectedClass() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())
    container.injectTransient({ Logger() })

    container.remove(AnyStore<String>.self)
    container.remove(Logger.self)

    let scope = container.createScope()
    XCTAssertNil(try? scope.provide(AnyStore<String>.self))
    XCTAssertNil(try? scope.provide(Logger.self))
  }

  func testReplacingInjectedClass() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    container.injectSingleton(AnotherStore().toAnyStore())

    let scope = container.createScope()
    let store: AnyStore<String> = try! scope.provide()
    XCTAssertEqual(store.get(), "<another-entity>")
  }

  func testSingletonEquality() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    let scope = container.createScope()
    let storeA: AnyStore<String> = try! scope.provide()
    let storeB: AnyStore<String> = try! scope.provide()
    
    XCTAssert(storeA === storeB)
  }

  func testTransientInequality() {
    let container = DependencyInjectionContainer()
    container.injectTransient({ Logger() })

    let scope = container.createScope()
    let storeA: Logger = try! scope.provide()
    let storeB: Logger = try! scope.provide()
    
    XCTAssert(storeA !== storeB)
  }

  func testScopedInequality() {
    let container = DependencyInjectionContainer()
    container.injectScoped({ Logger() })

    let scopeA = container.createScope()
    let storeA: Logger = try! scopeA.provide()

    let scopeB = container.createScope()
    let storeB: Logger = try! scopeB.provide()
    
    XCTAssert(storeA !== storeB)
  }

  func testScopedCacheEquality() {
    let container = DependencyInjectionContainer()
    container.injectScoped({ Logger() })

    let scopeA = container.createScope()
    let storeA: Logger = try! scopeA.provide()
    let storeB: Logger = try! scopeA.provide()
    
    XCTAssert(storeA === storeB)
  }

  func testPropertyWrapperAutoInjectsFromShared() {
    DefaultScope.scope.container.injectSingleton(SomeStore().toAnyStore())
    DefaultScope.scope.container.injectTransient({ Logger() })

    let usersStore: UsersStore = UsersStore()
    usersStore.logger.configure(forClass: self)

    XCTAssertEqual(usersStore.store.get(), "<entity>")
    XCTAssertEqual(usersStore.logger.info(message: "<logging>"), "SwiftAppTests.MainTests::<logging>")
  }

  func testPropertyWrapperWithMultipeLifecycles() {
    MultipleLifecycles.container.injectSingleton(HasIdSingleton())
    MultipleLifecycles.container.injectScoped({ HasIdScoped() })
    MultipleLifecycles.container.injectTransient({ HasIdTransient() })

    let multipleLifecyclesA = MultipleLifecycles()
    let multipleLifecyclesB = MultipleLifecycles()

    // Test singleton dep equality when providing from different instances
    XCTAssertEqual(multipleLifecyclesA.singleton.id, multipleLifecyclesB.singleton.id)

    // Test singleton dep equality when providing from different scopes
    XCTAssertEqual(multipleLifecyclesA.singleton.id, multipleLifecyclesA.singletonWithDifferentScope.id)
    
    // Test scoped dep inequality when providing from different scopes
    XCTAssertNotEqual(multipleLifecyclesA.scoped.id, multipleLifecyclesA.scopedWithDifferentScope.id)

    // Test scoped dep equality when providing from same scope
    XCTAssertEqual(multipleLifecyclesA.scoped.id, multipleLifecyclesA.scopedWithSameScope.id)

    // Test transient dep inequality when providing from same scope
    XCTAssertNotEqual(multipleLifecyclesA.transient.id, multipleLifecyclesA.transientWithSameScope.id)
  }
}

class UsersStore
{
  @Provide
  var store: AnyStore<String>

  @Provide
  var logger: Logger
}

protocol StoreProtocol 
{
  associatedtype Entity
  func get() -> Entity?
}

extension StoreProtocol
{
  func toAnyStore() -> AnyStore<Entity>
  {
    return AnyStore<Entity>(with: self)
  }
}

class AnyStore<T>: StoreProtocol
{
  typealias Entity = T
  private let getClosure: () -> Entity?

  init<StoreProtocolType: StoreProtocol>(with: StoreProtocolType) where StoreProtocolType.Entity == Entity 
  {
    self.getClosure = with.get
  }

  func get() -> Entity? {
    return self.getClosure()
  }
}

class SomeStore: StoreProtocol
{
  typealias Entity = String

  func get() -> Entity? {
      return "<entity>"
  }
}

class AnotherStore: StoreProtocol
{
  typealias Entity = String

  func get() -> Entity? {
      return "<another-entity>"
  }
}

class Logger
{
  private var prefix = ""

  func configure(forClass: AnyObject)
  {
    self.prefix = String(describing: forClass)
  }

  func info(message: String) -> String {
    return "\(self.prefix)::\(message)"
  }
}

protocol HasUniqueIdProtocol
{
  var id: String { get set }    
}

class HasIdSingleton: HasUniqueIdProtocol
{
  var id = UUID().uuidString
}

class HasIdScoped: HasUniqueIdProtocol
{
  var id = UUID().uuidString
}

class HasIdTransient: HasUniqueIdProtocol
{
  var id = UUID().uuidString
}

class MultipleLifecycles
{
  public static let container = DependencyInjectionContainer()
  private static let scopeA = MultipleLifecycles.container.createScope()
  private static let scopeB = MultipleLifecycles.container.createScope()

  @Provide(scopeA)
  var singleton: HasIdSingleton

  @Provide(scopeB)
  var singletonWithDifferentScope: HasIdSingleton

  @Provide(scopeA)
  var scoped: HasIdScoped

  @Provide(scopeA)
  var scopedWithSameScope: HasIdScoped

  @Provide(scopeB)
  var scopedWithDifferentScope: HasIdScoped

  @Provide(scopeA)
  var transient: HasIdTransient

  @Provide(scopeA)
  var transientWithSameScope: HasIdTransient
}

