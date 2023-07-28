// The Swift Programming Language
// https://docs.swift.org/swift-book

print("Hello, world!")

protocol Anything 
{
  
}

class TestClass: Anything
{
  private let batman: String

  init(batman: String) {
    self.batman = batman
  }
}