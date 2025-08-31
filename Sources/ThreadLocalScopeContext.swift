import Foundation

enum ScopeContext {
    private static let key = "ScopeContext.current"

    static var current: ServiceScope? {
        get { Thread.current.threadDictionary[key] as? ServiceScope }
        set { Thread.current.threadDictionary[key] = newValue }
    }
}