@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testInjectAndProvide() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    let scope = container.createScope()
    let store: AnyStore<String> = try! scope.provide()
    XCTAssertEqual(store.Get(), "<entity>")
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
    XCTAssertEqual(store.Get(), "<another-entity>")
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

    let usesStore = UsesStore()
    usesStore.logger.Configure(forClass: self)

    XCTAssertEqual(usesStore.store.Get(), "<entity>")
    XCTAssertEqual(usesStore.logger.Info(message: "<logging>"), "SwiftAppTests.MainTests::<logging>")
  }
}

class UsesStore
{
  @Provide
  var store: AnyStore<String>

  @Provide
  var logger: Logger
}

protocol StoreProtocol 
{
  associatedtype Entity
  func Get() -> Entity?
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
  private let GetClosure: () -> Entity?

  init<StoreProtocolType: StoreProtocol>(with: StoreProtocolType) where StoreProtocolType.Entity == Entity 
  {
    self.GetClosure = with.Get
  }

  func Get() -> Entity? {
    return self.GetClosure()
  }
}

class SomeStore: StoreProtocol
{
  typealias Entity = String

  func Get() -> Entity? {
      return "<entity>"
  }
}

class AnotherStore: StoreProtocol
{
  typealias Entity = String

  func Get() -> Entity? {
      return "<another-entity>"
  }
}

class Logger
{
  private var prefix = ""

  func Configure(forClass: AnyObject)
  {
    self.prefix = String(describing: forClass)
  }

  func Info(message: String) -> String {
    return "\(self.prefix)::\(message)"
  }
}