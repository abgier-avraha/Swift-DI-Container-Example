# Swift DI Container Example

Very basic Swift DI container with no fancy reflection. Dotnet like API.

What's the point of scoped dependencies when you have to use property wrappers to manually declare the scope you want? I have idea.

Please refer to `Tests/main.test.swift` for example code utilising Protocols and Type Erasure.

## Inject

```swift
  let container = DependencyInjectionContainer()
  container.injectSingleton(SomeStore().toAnyStore())
  container.injectTransient({ Logger() })
  container.injectScoped({ AnotherService().toAnyService() })
```

## Provide

### Through Property Wrapper with Thread Local Scope

```swift
class UsesStore
{
  @Provide
  var store: AnyStore<String>
}
```

### Through Property Wrapper with Custom Scope

```swift
class UsesStore
{
  @Provide(scope)
  var store: AnyStore<String>
}
```

### Through Provide Method

```swift
  let scope = container.createScope()
  let store: AnyStore<String> = try! scope.provide()
```

Or

```swift
  let scope = container.createScope()
  let store = try! scope.provide(AnyStore<String>.self)
```
