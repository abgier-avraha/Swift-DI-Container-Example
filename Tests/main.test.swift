@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testGeneratedString() {
    let store = SomeStore().toAnyStore()

    var singletonMap: [String: AnyObject] = [:]
    singletonMap[AnyStore<String>.self] = SomeStore().toAnyStore()

    XCTAssertEqual(store.Get(), "<entity>")
  }
}

// TODO: create a static defaultContainer
// TODO: property wrapper dependency injection (has optional container arg, uses default container by default)
// TODO: swapping object in default containers for easy test setup

// Allows for types as keys
extension Dictionary where Key : LosslessStringConvertible
{
  subscript(index: Any.Type) -> Value?
   {
      get
      {
         return self[String(describing: index) as! Key]
      }
      set(newValue)
      {
         self[String(describing: index) as! Key] = newValue
      }
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