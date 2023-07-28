@testable import SwiftApp
import XCTest

class MainTests: XCTestCase {
  func testGeneratedString() {
    let _ = TestClass(batman: "WOW")
    XCTAssertEqual("test", "test")
  }
}