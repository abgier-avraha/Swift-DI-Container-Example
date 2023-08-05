# Swift DI Container Example

Very basic Swift DI container with no fancy reflection. Dotnet like API.

Please refer to `Tests/main.test.swift` for example code utilising Protocols and Type Erasure.

## Inject

### Using Default Scope

```swift
  DefaultScope.scope.container.injectSingleton(SomeStore().toAnyStore())
  DefaultScope.scope.container.({ SomeLogger().toAnyLogger() })
  DefaultScope.scope.container.injectTransient({ Logger() })
```

### Using Custom Container

```swift
  let container = DependencyInjectionContainer()
  container.injectSingleton(SomeStore().toAnyStore())
  container.injectTransient({ SomeLogger().toAnyLogger() })
  container.injectScoped({ SomeLogger().toAnyLogger() })
```

## Provide

### Through Property Wrapper with Default Scope

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
