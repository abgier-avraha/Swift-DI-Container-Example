import XCTest

@testable import SwiftApp

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

  func testMultipleLifecycles() {
    let container = DependencyInjectionContainer()

    container.injectSingleton(HasIdSingleton())
    container.injectScoped({ HasIdScoped() })
    container.injectTransient({ HasIdTransient() })

    let scopeA: ServiceScope = container.createScope()
    let scopeB: ServiceScope = container.createScope()

    // Test singleton dep equality when providing from different scopes
    XCTAssertEqual(
      try! scopeA.provide(HasIdSingleton.self).id, try! scopeB.provide(HasIdSingleton.self).id)

    // Test scoped dep inequality when providing from different scopes
    XCTAssertNotEqual(
      try! scopeA.provide(HasIdScoped.self).id, try! scopeB.provide(HasIdScoped.self).id)

    // Test scoped dep equality when providing from same scope
    XCTAssertEqual(
      try! scopeA.provide(HasIdScoped.self).id, try! scopeA.provide(HasIdScoped.self).id)

    // Test transient dep inequality when providing from same scope
    XCTAssertNotEqual(
      try! scopeA.provide(HasIdTransient.self).id, try! scopeA.provide(HasIdTransient.self).id)
  }

  func testPropertyWrapperWithMultipleLifecycles() {
    let container = DependencyInjectionContainer()

    container.injectSingleton(HasIdSingleton())
    container.injectScoped({ HasIdScoped() })
    container.injectTransient({ HasIdTransient() })
    container.injectTransient {
      MultipleLifecycles()
    }

    let scopeA: ServiceScope = container.createScope()
    let scopeB: ServiceScope = container.createScope()

    let scopeAInstance: MultipleLifecycles = try! scopeA.provide()
    let duplicateScopeAInstance: MultipleLifecycles = try! scopeA.provide()
    let scopeBInstance: MultipleLifecycles = try! scopeB.provide()

    // Test singleton dep equality when providing from different scopes
    XCTAssertEqual(
      scopeAInstance.singleton.id, scopeBInstance.singleton.id)

    // Test scoped dep inequality when providing from different scopes
    XCTAssertNotEqual(
      scopeAInstance.scoped.id, scopeBInstance.scoped.id)

    // Test scoped dep equality when providing from same scope
    XCTAssertEqual(
      scopeAInstance.scoped.id, duplicateScopeAInstance.scoped.id)

    // Test transient dep inequality when providing from same scope
    XCTAssertNotEqual(
      scopeAInstance.transient.id, duplicateScopeAInstance.transient.id)
  }

  func testNestedPropertyWrappers() {
    let container = DependencyInjectionContainer()

    container.injectTransient({ SomeStore().toAnyStore() })
    container.injectTransient({ Logger() })
    container.injectTransient({ UsersStore() })
    container.injectTransient({ NestedTest() })

    let scope: ServiceScope = container.createScope()

    let nestedTest: NestedTest = try! scope.provide()

    // Test singleton dep equality when providing from different scopes
    XCTAssertNotNil(nestedTest)
    XCTAssertNotNil(nestedTest.userStore)
    XCTAssertNotNil(nestedTest.userStore.logger)
    XCTAssertNotNil(nestedTest.userStore.store)
  }
}

class UsersStore {
  @Provide
  var store: AnyStore<String>

  @Provide
  var logger: Logger
}

protocol StoreProtocol {
  associatedtype Entity
  func get() -> Entity?
}

extension StoreProtocol {
  func toAnyStore() -> AnyStore<Entity> {
    return AnyStore<Entity>(with: self)
  }
}

class AnyStore<T>: StoreProtocol {
  typealias Entity = T
  private let getClosure: () -> Entity?

  init<StoreProtocolType: StoreProtocol>(with: StoreProtocolType)
  where StoreProtocolType.Entity == Entity {
    self.getClosure = with.get
  }

  func get() -> Entity? {
    return self.getClosure()
  }
}

class SomeStore: StoreProtocol {
  typealias Entity = String

  func get() -> Entity? {
    return "<entity>"
  }
}

class AnotherStore: StoreProtocol {
  typealias Entity = String

  func get() -> Entity? {
    return "<another-entity>"
  }
}

class Logger {
  private var prefix = ""

  func configure(forClass: AnyObject) {
    self.prefix = String(describing: forClass)
  }

  func info(message: String) -> String {
    return "\(self.prefix)::\(message)"
  }
}

protocol HasUniqueIdProtocol {
  var id: String { get set }
}

class HasIdSingleton: HasUniqueIdProtocol {
  var id = UUID().uuidString
}

class HasIdScoped: HasUniqueIdProtocol {
  var id = UUID().uuidString
}

class HasIdTransient: HasUniqueIdProtocol {
  var id = UUID().uuidString
}

class MultipleLifecycles {
  @Provide
  var singleton: HasIdSingleton

  @Provide
  var scoped: HasIdScoped

  @Provide
  var transient: HasIdTransient
}

class NestedTest {
  @Provide
  var userStore: UsersStore
}
