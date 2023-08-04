# Swift DI Container Example

Very basic Swift DI container with no fancy reflection.

Please refer to `Tests/main.test.swift` for example code utilising Protocols and Type Erasure.

## Inject

### Using Default Shared Container

```swift
  SharedContainer.container.injectSingleton(SomeStore().toAnyStore())
  SharedContainer.container.injectTransient({ Logger() })
```

### Using Custom Container

```swift
  let container = DependencyInjectionContainer()
  container.injectSingleton(SomeStore().toAnyStore())
  container.injectTransient({ SomeLogger().toAnyLogger() })
```

## Provide

### Through Property Wrapper with Default Shared Container

```swift
class UsesStore
{
  @Provide
  var store: AnyStore<String>
}
```

### Through Property Wrapper with Custom Container

```swift
class UsesStore
{
  @Provide(container)
  var store: AnyStore<String>
}
```

### Through Provide Method

```swift
  let store: AnyStore<String> = try! container.provide()
```

Or

```swift
  let store = try! container.provide(AnyStore<String>.self)
```
