@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testInjectAndProvide() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    let store: AnyStore<String> = try! container.provide()
    XCTAssertEqual(store.Get(), "<entity>")
  }

  func testOverwritingInjectedClass() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    container.injectSingleton(AnotherStore().toAnyStore())

    let store: AnyStore<String> = try! container.provide()
    XCTAssertEqual(store.Get(), "<another-entity>")
  }

  func testSingletonEquality() {
    let container = DependencyInjectionContainer()
    container.injectSingleton(SomeStore().toAnyStore())

    let storeA: AnyStore<String> = try! container.provide()
    let storeB: AnyStore<String> = try! container.provide()
    
    XCTAssert(storeA === storeB)
  }
  

  func testTransientInequality() {
   let container = DependencyInjectionContainer()
    container.injectTransient({ SomeStore().toAnyStore() })

    let storeA: AnyStore<String> = try! container.provide()
    let storeB: AnyStore<String> = try! container.provide()
    
    XCTAssert(storeA !== storeB)
  }

  func testPropertyWrapperAutoInjectsFromShared() {
    SharedContainer.container.injectSingleton(SomeStore().toAnyStore())
    SharedContainer.container.injectTransient({ Logger() })

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