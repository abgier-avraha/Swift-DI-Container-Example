@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testGeneratedString() {
    let container = DependencyInjectionContainer()
    
    container.inject(use: SomeStore().toAnyStore(), forType:  AnyStore<String>.self)

    let store = try! container.provide(forType:  AnyStore<String>.self)

    XCTAssertEqual(store.Get(), "<entity>")
  }
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