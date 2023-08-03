@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testInjectAndProvide() {
    let container = DependencyInjectionContainer()
    container.inject(SomeStore().toAnyStore())

    let store: AnyStore<String> = try! container.provide()
    XCTAssertEqual(store.Get(), "<entity>")
  }

  func testReplaceExistingInjectionAndProvide() {
    let container = DependencyInjectionContainer()
    container.inject(SomeStore().toAnyStore())

    container.inject(AnotherStore().toAnyStore())

    let store: AnyStore<String> = try! container.provide()
    XCTAssertEqual(store.Get(), "<another-entity>")
  }

  func propertyWrapperAutoInjectsFromShared() {
    SharedContainer.container.inject(SomeStore().toAnyStore())

    let usesStore = UsesStore()
    XCTAssertEqual(usesStore.store.Get(), "<entity>")
  }
}

class UsesStore
{
  @Provide
  var store: AnyStore<String>
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