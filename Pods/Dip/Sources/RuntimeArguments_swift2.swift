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

#if !swift(>=3.0)

  extension DependencyContainer {
    
    /**
     Register factory for type `T` and associate it with an optional tag.
     
     - parameters:
        - scope: The scope to use for instance created by the factory. Default value is `Shared`.
        - type: Type to register definition for. Default value is return value of factory.
        - tag: The arbitrary tag to associate this factory with. Pass `nil` to associate with any tag. Default value is `nil`.
        - factory: The factory that produces instance of `type`. Will be used to resolve instances of `type`.
     
     - returns: A registered definition.
     
     - note: You should cast the factory return type to the protocol you want to register it for
             (unless you want to register concrete type) or provide `type` parameter.
     
     - seealso: `Definition`, `ComponentScope`, `DependencyTagConvertible`
     
     **Example**:
     ```swift
     //Register ServiceImp as Service
     container.register { ServiceImp() as Service }
     
     //Register ServiceImp as Service named by "service"
     container.register(tag: "service") { ServiceImp() as Service }
     
     //Register unique ServiceImp as Service
     container.register(.unique) { ServiceImp() as Service }
     
     //Register ClientImp as Client and resolve it's service dependency
     container.register { try ClientImp(service: container.resolve() as Service) as Client }
     
     //Register ServiceImp as concrete type
     container.register { ServiceImp() }
     container.register(factory: ServiceImp.init)
     
     //Register ServiceImp as Service
     container.register(Service.self, factory: ServiceImp.init)
     
     //Register ClientImp as Client
     container.register(Client.self, factory: ClientImp.init(service:))
     ```
     */
    public func register<T>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: () throws -> T) -> Definition<T, ()> {
      let definition = DefinitionBuilder<T, ()> {
        $0.scope = scope
        $0.factory = factory
        }.build()
      register(definition, tag: tag)
      return definition
    }
    
    /**
     Register generic factory and auto-wiring factory and associate it with an optional tag.
     
     - parameters:
        - tag: The arbitrary tag to associate this factory with. Pass `nil` to associate with any tag. Default value is `nil`.
        - scope: The scope to use for instance created by the factory.
        - factory: The factory to register.
        - numberOfArguments: The number of factory arguments. Will be used on auto-wiring to sort definitions.
        - autoWiringFactory: The factory to be used on auto-wiring to resolve component.
     
     - returns: A registered definition.
     
     - note: You _should not_ call this method directly, instead call any of other `register` methods.
             You _should_ use this method only to register dependency with more runtime arguments
             than _Dip_ supports (currently it's up to six) like in the following example:
     
     ```swift
     public func register<T, A, B, C, ...>(_ scope: ComponentScope = .shared, type: T.Type = T.self, tag: Tag? = nil, factory: (A, B, C, ...) throws -> T) -> Definition<T, (A, B, C, ...)> {
        return register(scope: scope, type: type, tag: tag, factory: factory, numberOfArguments: ...) { container, tag in
          try factory(container.resolve(tag: tag), ...)
        }
     }
     ```
     
     Though before you do so you should probably review your design and try to reduce number of depnedencies.
     */
    public func register<T, U>(scope: ComponentScope, type: T.Type, tag: DependencyTagConvertible?, factory: (U) throws -> T, numberOfArguments: Int, autoWiringFactory: (DependencyContainer, Tag?) throws -> T) -> Definition<T, U> {
      let definition = DefinitionBuilder<T, U> {
        $0.scope = scope
        $0.factory = factory
        $0.numberOfArguments = numberOfArguments
        $0.autoWiringFactory = autoWiringFactory
        }.build()
      register(definition, tag: tag)
      return definition
    }
    
    // MARK: 1 Runtime Argument
    
    /**
     Register factory that accepts one runtime argument of type `A`. You can use up to six runtime arguments.
     
     - note: You can have several factories with different number or types of arguments registered for same type,
             optionally associated with some tags. When container resolves that type it matches the type,
             __number__, __types__ and __order__ of runtime arguments and optional tag that you pass to `resolve(tag:arguments:)` method.
     
     - parameters:
        - tag: The arbitrary tag to associate this factory with. Pass `nil` to associate with any tag. Default value is `nil`.
        - scope: The scope to use for this component. Default value is `Shared`.
        - factory: The factory to register.
     
     - seealso: `register(_:type:tag:factory:)`
     */
    public func register<T, A>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A) throws -> T) -> Definition<T, A> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 1) { container, tag in try factory(container.resolve(tag: tag)) }
    }
    
    /**
     Resolve type `T` using one runtime argument.
     
     - note: When resolving a type container will first try to use definition
             that exactly matches types of arguments that you pass to resolve method.
             If it fails or no such definition is found container will try to _auto-wire_ component.
             For that it will iterate through all the definitions registered for that type
             which factories accept any number of runtime arguments and are tagged with the same tag,
             passed to `resolve` method, or with no tag. Container will try to use these definitions
             to resolve a component one by one until one of them succeeds, starting with tagged definitions
             in order of decreasing their's factories number of arguments. If none of them succeds it will
             throw an error. If it finds two definitions with the same number of arguments - it will throw
             an error.
     
     - parameters:
        - tag: The arbitrary tag to lookup registered definition.
        - arg1: The first argument to pass to the definition's factory.
     
     - throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`
     
     - returns: An instance of type `T`.
     
     - seealso: `register(_:tag:factory:)`, `resolve(tag:builder:)`
     */
    public func resolve<T, A>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1) }
    }
    
    ///- seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory(arg1) }
    }
    
    // MARK: 2 Runtime Arguments
    
    /// - seealso: `register(_:type:tag:factory:)`
    public func register<T, A, B>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A, B) throws -> T) -> Definition<T, (A, B)> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 2) { container, tag in try factory(container.resolve(tag: tag), container.resolve(tag: tag)) }
    }
    
    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1, arg2) }
    }
    
    ///- seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory((arg1, arg2)) }
    }
    
    // MARK: 3 Runtime Arguments
    
    /// - seealso: `register(_:type:tag:factory:)`
    public func register<T, A, B, C>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A, B, C) throws -> T) -> Definition<T, (A, B, C)> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 3)  { container, tag in try factory(container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag)) }
    }
    
    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3) }
    }
    
    ///- seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3)) }
    }
    
    // MARK: 4 Runtime Arguments
    
    /// - seealso: `register(_:type:tag:factory:)`
    public func register<T, A, B, C, D>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A, B, C, D) throws -> T) -> Definition<T, (A, B, C, D)> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 4) { container, tag in try factory(container.resolve(tag: tag),  container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag)) }
    }
    
    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4) }
    }
    
    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4)) }
    }
    
    // MARK: 5 Runtime Arguments
    
    /// - seealso: `register(_:type:tag:factory:)`
    public func register<T, A, B, C, D, E>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A, B, C, D, E) throws -> T) -> Definition<T, (A, B, C, D, E)> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 5) { container, tag in try factory(container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag)) }
    }
    
    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D, E>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4, arg5) }
    }
    
    ///- seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D, E>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4, arg5)) }
    }
    
    // MARK: 6 Runtime Arguments
    
    /// - seealso: `register(_:type:tag:factory:)`
    public func register<T, A, B, C, D, E, F>(scope: ComponentScope = .Shared, type: T.Type = T.self, tag: DependencyTagConvertible? = nil, factory: (A, B, C, D, E, F) throws -> T) -> Definition<T, (A, B, C, D, E, F)> {
      return register(scope, type: type, tag: tag, factory: factory, numberOfArguments: 6) { container, tag in try factory(container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag), container.resolve(tag: tag)) }
    }
    
    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D, E, F>(tag tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E, _ arg6: F) throws -> T {
      return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4, arg5, arg6) }
    }
    
    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D, E, F>(type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E, _ arg6: F) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4, arg5, arg6)) }
    }
    
  }

#endif
