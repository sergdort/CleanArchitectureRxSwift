//
// Dip
//
// Copyright (c) 2015 Olivier Halligon <olivier@halligon.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

extension DependencyContainer {
  
  /**
   Resolves properties of passed object wrapped with `Injected<T>` or `InjectedWeak<T>`
   */
  func autoInjectProperties(in instance: Any) throws {
    let mirror = Mirror(reflecting: instance)
    
    //mirror only contains class own properties
    //so we need to walk through super class mirrors
    //to resolve super class auto-injected properties
    var superClassMirror = mirror._superclassMirror
    while superClassMirror != nil {
      try superClassMirror?.children.forEach(resolveChild)
      superClassMirror = superClassMirror?._superclassMirror
    }
    
    try mirror.children.forEach(resolveChild)
  }
  
  private func resolveChild(child: Mirror.Child) throws {
    #if swift(>=3.0)
      //HOTFIX for https://bugs.swift.org/browse/SR-2282
      guard !String(describing: type(of: child.value)).has(prefix: "ImplicitlyUnwrappedOptional") else { return }
    #endif
    guard let injectedPropertyBox = child.value as? AutoInjectedPropertyBox else { return }
    
    #if swift(>=3.0)
      let wrappedType = type(of: injectedPropertyBox).wrappedType
    #else
      let wrappedType = injectedPropertyBox.dynamicType.wrappedType
    #endif
    let contextKey = DefinitionKey(type: wrappedType, typeOfArguments: Void.self, tag: context.tag)
    try inContext(key:contextKey, injectedInType: context?.resolvingType, injectedInProperty: child.label, logErrors: false) {
      try injectedPropertyBox.resolve(self)
    }
  }
  
}

/**
 Implement this protocol if you want to use your own type to wrap auto-injected properties
 instead of using `Injected<T>` or `InjectedWeak<T>` types.
 
 **Example**:
 
 ```swift
 class MyCustomBox<T> {
   private(set) var value: T?
   init() {}
 }
 
 extension MyCustomBox: AutoInjectedPropertyBox {
   static var wrappedType: Any.Type { return T.self }
 
   func resolve(container: DependencyContainer) throws {
     value = try container.resolve() as T
   }
 }
 ```

*/
public protocol AutoInjectedPropertyBox: class {
  ///The type of wrapped property.
  static var wrappedType: Any.Type { get }
  
  #if swift(>=3.0)
  /**
   This method will be called by `DependencyContainer` during processing resolved instance properties.
   In this method you should resolve an instance for wrapped property and store a reference to it.
   
   - parameter container: A container to be used to resolve an instance
   
   - note: This method is not intended to be called manually, `DependencyContainer` will call it by itself.
   */
  func resolve(_ container: DependencyContainer) throws
  #else
  /**
   This method will be called by `DependencyContainer` during processing resolved instance properties.
   In this method you should resolve an instance for wrapped property and store a reference to it.
   
   - parameter container: A container to be used to resolve an instance
   
   - note: This method is not intended to be called manually, `DependencyContainer` will call it by itself.
   */
  func resolve(container: DependencyContainer) throws
  #endif
}

/**
 Use this wrapper to identify _strong_ properties of the instance that should be
 auto-injected by `DependencyContainer`. Type T can be any type.

 - warning: Do not define this property as optional or container will not be able to inject it.
            Instead define it with initial value of `Injected<T>()`.

 **Example**:

 ```swift
 class ClientImp: Client {
   var service = Injected<Service>()
 }
 ```
 - seealso: `InjectedWeak`

*/
public final class Injected<T>: _InjectedPropertyBox<T>, AutoInjectedPropertyBox {
  
  ///The type of wrapped property.
  public static var wrappedType: Any.Type {
    return T.self
  }

  ///Wrapped value.
  public internal(set) var value: T? {
    didSet {
      if let value = value { didInject(value) }
    }
  }

  #if swift(>=3.0)
  /**
   Creates a new wrapper for auto-injected property.
   
   - parameters:
      - required: Defines if the property is required or not.
                  If container fails to inject required property it will als fail to resolve
                  the instance that defines that property. Default is `true`.
      - tag: An optional tag to use to lookup definitions when injecting this property. Default is `nil`.
      - didInject: Block that will be called when concrete instance is injected in this property.
                   Similar to `didSet` property observer. Default value does nothing.
   */
  public convenience init(required: Bool = true, didInject: @escaping (T) -> () = { _ in }) {
    self.init(value: nil, required: required, tag: nil, overrideTag: false, didInject: didInject)
  }
  
  public convenience init(required: Bool = true, tag: DependencyTagConvertible?, didInject: @escaping (T) -> () = { _ in }) {
    self.init(value: nil, required: required, tag: tag, overrideTag: true, didInject: didInject)
  }

  init(value: T?, required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: @escaping (T) -> ()) {
    self.value = value
    super.init(required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }
  
  public func resolve(_ container: DependencyContainer) throws {
    let resolved: T? = try super.resolve(with: container)
    value = resolved
  }

  /// Returns a new wrapper with provided value.
  public func setValue(_ value: T?) -> Injected {
    guard (required && value != nil) || !required else {
      fatalError("Can not set required property to nil.")
    }
    
    return Injected(value: value, required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }

  #else
  init(value: T?, required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: (T) -> ()) {
    self.value = value
    super.init(required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }
  #endif

}

/**
 Use this wrapper to identify _weak_ properties of the instance that should be
 auto-injected by `DependencyContainer`. Type T should be a **class** type.
 Otherwise it will cause runtime exception when container will try to resolve the property.
 Use this wrapper to define one of two circular dependencies to avoid retain cycle.
 
 - note: The only difference between `InjectedWeak` and `Injected` is that `InjectedWeak` uses 
         _weak_ reference to store underlying value, when `Injected` uses _strong_ reference. 
         For that reason if you resolve instance that has a _weak_ auto-injected property this property
         will be released when `resolve` will complete.
 
 Use `InjectedWeak<T>` to define one of two circular dependecies if another dependency is defined as `Injected<U>`.
 This will prevent a retain cycle between resolved instances.

 - warning: Do not define this property as optional or container will not be able to inject it.
            Instead define it with initial value of `InjectedWeak<T>()`.

 **Example**:
 
 ```swift
 class ServiceImp: Service {
   var client = InjectedWeak<Client>()
 }

 ```
 
 - seealso: `Injected`
 
 */
public final class InjectedWeak<T>: _InjectedPropertyBox<T>, AutoInjectedPropertyBox {

  //Only classes (means AnyObject) can be used as `weak` properties
  //but we can not make <T: AnyObject> because that will prevent using protocol as generic type
  //so we just rely on user reading documentation and passing AnyObject in runtime
  //also we will throw fatal error if type can not be casted to AnyObject during resolution.

  ///The type of wrapped property.
  public static var wrappedType: Any.Type {
    return T.self
  }

  var valueBox: WeakBox<T>? = nil {
    didSet {
      if let value = value { didInject(value) }
    }
  }
  
  ///Wrapped value.
  public var value: T? {
    return valueBox?.value
  }

  #if swift(>=3.0)
  init(value: T?, required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: @escaping (T) -> ()) {
    self.valueBox = value.map(WeakBox.init)
    super.init(required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }
  /**
   Creates a new wrapper for weak auto-injected property.
   
   - parameters:
      - required: Defines if the property is required or not.
                  If container fails to inject required property it will als fail to resolve
                  the instance that defines that property. Default is `true`.
      - tag: An optional tag to use to lookup definitions when injecting this property. Default is `nil`.
      - didInject: Block that will be called when concrete instance is injected in this property.
                   Similar to `didSet` property observer. Default value does nothing.
   */
  public convenience init(required: Bool = true, didInject: @escaping (T) -> () = { _ in }) {
    self.init(value: nil, required: required, tag: nil, overrideTag: false, didInject: didInject)
  }
  
  public convenience init(required: Bool = true, tag: DependencyTagConvertible?, didInject: @escaping (T) -> () = { _ in }) {
    self.init(value: nil, required: required, tag: tag, overrideTag: true, didInject: didInject)
  }
  
  public func resolve(_ container: DependencyContainer) throws {
    let resolved: T? = try super.resolve(with: container)
    valueBox = resolved.map(WeakBox.init)
  }

  /// Returns a new wrapper with provided value.
  public func setValue(_ value: T?) -> InjectedWeak {
    guard (required && value != nil) || !required else {
      fatalError("Can not set required property to nil.")
    }
    
    return InjectedWeak(value: value, required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }

  #else
  init(value: T?, required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: (T) -> ()) {
    self.valueBox = value.map(WeakBox.init)
    super.init(required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
  }
  #endif

}

class _InjectedPropertyBox<T> {

  let required: Bool
  let didInject: (T) -> ()
  let tag: DependencyContainer.Tag?
  let overrideTag: Bool

  #if swift(>=3.0)
  init(required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: @escaping (T) -> () = { _ in }) {
    self.required = required
    self.tag = tag?.dependencyTag
    self.overrideTag = overrideTag
    self.didInject = didInject
  }
  #else
  init(required: Bool = true, tag: DependencyTagConvertible?, overrideTag: Bool, didInject: (T) -> () = { _ in }) {
    self.required = required
    self.tag = tag?.dependencyTag
    self.overrideTag = overrideTag
    self.didInject = didInject
  }
  #endif

  func resolve(with container: DependencyContainer) throws -> T? {
    let tag = overrideTag ? self.tag : container.context.tag
    do {
      container.context.key = container.context.key.tagged(with: tag)
      let key = DefinitionKey(type: T.self, typeOfArguments: Void.self, tag: tag?.dependencyTag)
      return try resolve(with: container, key: key, builder: { factory in try factory() }) as? T
    }
    catch {
        let error = DipError.autoInjectionFailed(label: container.context.injectedInProperty, type: container.context.resolvingType, underlyingError: error)
      if required {
        throw error
      }
      else {
        log(level: .Errors, error)
        return nil
      }
    }
  }
  
  private func resolve<U>(with container: DependencyContainer, key: DefinitionKey, builder: ((U) throws -> Any) throws -> Any) throws -> Any {
    return try container._resolve(key: key, builder: { definition throws -> Any in
      try builder(definition.weakFactory)
    })
  }
  
}


