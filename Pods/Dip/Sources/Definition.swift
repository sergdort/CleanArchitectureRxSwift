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

///A key used to store definitons in a container.
public struct DefinitionKey : Hashable, CustomStringConvertible {
  public let type: Any.Type
  public let typeOfArguments: Any.Type
  public private(set) var tag: DependencyContainer.Tag?

  init(type: Any.Type, typeOfArguments: Any.Type, tag: DependencyContainer.Tag? = nil) {
    self.type = type
    self.typeOfArguments = typeOfArguments
    self.tag = tag
  }
  
  public var hashValue: Int {
    return "\(type)-\(typeOfArguments)-\(tag)".hashValue
  }
  
  public var description: String {
    return "type: \(type), arguments: \(typeOfArguments), tag: \(tag.desc)"
  }
  
  func tagged(with tag: DependencyContainer.Tag?) -> DefinitionKey {
    var tagged = self
    tagged.tag = tag
    return tagged
  }
  
}

/// Check two definition keys on equality by comparing their `type`, `factoryType` and `tag` properties.
public func ==(lhs: DefinitionKey, rhs: DefinitionKey) -> Bool {
  return
    lhs.type == rhs.type &&
      lhs.typeOfArguments == rhs.typeOfArguments &&
      lhs.tag == rhs.tag
}

///Dummy protocol to store definitions for different types in collection
public protocol DefinitionType: class { }

/**
 `Definition<T, U>` describes how instances of type `T` should be created when this type is resolved by the `DependencyContainer`.
 
 - `T` is the type of the instance to resolve
 - `U` is the type of runtime arguments accepted by factory that will create an instance of T.
 
 For example `Definition<Service, String>` is the type of definition that will create an instance of type `Service` using factory that accepts `String` argument.
*/
public final class Definition<T, U>: DefinitionType {
  public typealias F = (U) throws -> T
  
  //MARK: - _Definition

  weak var container: DependencyContainer?
  
  let factory: F
  let scope: ComponentScope
  var weakFactory: ((Any) throws -> Any)!
  var resolveProperties: ((DependencyContainer, Any) throws -> ())?
  
  #if swift(>=3.0)
  init(scope: ComponentScope, factory: @escaping F) {
    self.factory = factory
    self.scope = scope
  }
  #else
  init(scope: ComponentScope, factory: F) {
    self.factory = factory
    self.scope = scope
  }
  #endif

  #if swift(>=3.0)
  /**
   Set the block that will be used to resolve dependencies of the instance.
   This block will be called before `resolve(tag:)` returns.
   
   - parameter block: The block to resolve property dependencies of the instance.
   
   - returns: modified definition
   
   - note: To resolve circular dependencies at least one of them should use this block
           to resolve its dependencies. Otherwise the application will enter an infinite loop and crash.
   
   - note: You can call this method several times on the same definition. 
           Container will call all provided blocks in the same order.
   
   **Example**
   
   ```swift
   container.register { ClientImp(service: try container.resolve() as Service) as Client }
   
   container.register { ServiceImp() as Service }
     .resolvingProperties { container, service in
       service.client = try container.resolve() as Client
     }
   ```
   
   */
  @discardableResult public func resolvingProperties(_ block: @escaping (DependencyContainer, T) throws -> ()) -> Definition {
    if let oldBlock = self.resolveProperties {
      self.resolveProperties = {
        try oldBlock($0, $1 as! T)
        try block($0, $1 as! T)
      }
    }
    else {
      self.resolveProperties = { try block($0, $1 as! T) }
    }
    return self
  }
  #else
  /**
   Set the block that will be used to resolve dependencies of the instance.
   This block will be called before `resolve(tag:)` returns.
   
   - parameter block: The block to resolve property dependencies of the instance.
   
   - returns: modified definition
   
   - note: To resolve circular dependencies at least one of them should use this block
           to resolve its dependencies. Otherwise the application will enter an infinite loop and crash.
   
   - note: You can call this method several times on the same definition.
           Container will call all provided blocks in the same order.
   
   **Example**
   
   ```swift
   container.register { ClientImp(service: try container.resolve() as Service) as Client }
   
   container.register { ServiceImp() as Service }
     .resolvingProperties { container, service in
       service.client = try container.resolve() as Client
   }
   ```
   
   */
  public func resolvingProperties(block: (DependencyContainer, T) throws -> ()) -> Definition {
    if let oldBlock = self.resolveProperties {
      self.resolveProperties = {
        try oldBlock($0, $1 as! T)
        try block($0, $1 as! T)
      }
    }
    else {
      self.resolveProperties = { try block($0, $1 as! T) }
    }
    return self
  }
  #endif

  /// Calls `resolveDependencies` block if it was set.
  func resolveProperties(of instance: Any, container: DependencyContainer) throws {
    guard let resolvedInstance = instance as? T else { return }
    if let forwardsTo = forwardsTo {
      try forwardsTo.resolveProperties(of: resolvedInstance, container: container)
    }
    if let resolveProperties = self.resolveProperties {
      try resolveProperties(container, resolvedInstance)
    }
  }
  
  //MARK: - AutoWiringDefinition
  
  var autoWiringFactory: ((DependencyContainer, DependencyContainer.Tag?) throws -> Any)?
  var numberOfArguments: Int = 0
  
  //MARK: - TypeForwardingDefinition
  
  /// Types that can be resolved using this definition.
  private(set) var implementingTypes: [Any.Type] = [(T?).self, (T!).self]
  
  /// Return `true` if type can be resolved using this definition
  func doesImplements(type aType: Any.Type) -> Bool {
    return implementingTypes.contains(where: { $0 == aType })
  }
  
  //MARK: - _TypeForwardingDefinition

  /// Adds type as being able to be resolved using this definition
  func _implements(type aType: Any.Type) {
    _implements(types: [aType])
  }
  
  /// Adds types as being able to be resolved using this definition
  func _implements(types aTypes: [Any.Type]) {
    implementingTypes.append(contentsOf: aTypes.filter({ !doesImplements(type: $0) }))
  }
  
  /// Definition to which resolution will be forwarded to
  weak var forwardsTo: _TypeForwardingDefinition? {
    didSet {
      //both definitions (self and forwardsTo) can resolve
      //each other types and each other implementing types
      //this relationship can be used to reuse previously resolved instances
      if let forwardsTo = forwardsTo {
        _implements(type: forwardsTo.type)
        _implements(types: forwardsTo.implementingTypes)
        
        //definitions for types that can be resolved by `forwardsTo` definition
        //can also be used to resolve self type and it's implementing types
        //this way container properly reuses previosly resolved instances
        //when there are several forwarded definitions
        //see testThatItReusesInstanceResolvedByTypeForwarding)
        for definition in forwardsTo.forwardsFrom {
          definition._implements(type: type)
          definition._implements(types: implementingTypes)
        }
        
        //forwardsTo can be used to resolve self type and it's implementing types
        forwardsTo._implements(type: type)
        forwardsTo._implements(types: implementingTypes)
        forwardsTo.forwardsFrom.append(self)
      }
    }
  }
  
  /// Definitions that will forward resolution to this definition
  var forwardsFrom: [_TypeForwardingDefinition] = []
  
}

//MARK: - _Definition

protocol _Definition: DefinitionType, AutoWiringDefinition, TypeForwardingDefinition {
  var type: Any.Type { get }
  var scope: ComponentScope { get }
  var weakFactory: ((Any) throws -> Any)! { get }
  func resolveProperties(of instance: Any, container: DependencyContainer) throws
  var container: DependencyContainer? { get set }
}

//MARK: - Type Forwarding

protocol _TypeForwardingDefinition: TypeForwardingDefinition, _Definition {
  weak var forwardsTo: _TypeForwardingDefinition? { get }
  var forwardsFrom: [_TypeForwardingDefinition] { get set }
  func _implements(type aType: Any.Type)
  func _implements(types aTypes: [Any.Type])
}

extension Definition: _TypeForwardingDefinition {
  var type: Any.Type {
    return T.self
  }
}

extension Definition: CustomStringConvertible {
  public var description: String {
    return "type: \(T.self), factory: \(F.self), scope: \(scope)"
  }
}

//MARK: - Definition Builder

/// Internal class used to build definition
class DefinitionBuilder<T, U> {
  typealias F = (U) throws -> T
  
  var scope: ComponentScope!
  var factory: F!
  
  var numberOfArguments: Int = 0
  var autoWiringFactory: ((DependencyContainer, DependencyContainer.Tag?) throws -> T)?
  
  var forwardsTo: _Definition?
  
  init(configure: (DefinitionBuilder) -> ()) {
    configure(self)
  }
  
  func build() -> Definition<T, U> {
    let factory = self.factory!
    let definition = Definition<T, U>(scope: scope, factory: factory)
    definition.numberOfArguments = numberOfArguments
    definition.autoWiringFactory = autoWiringFactory
    definition.weakFactory = { try factory($0 as! U) }
    definition.forwardsTo = forwardsTo as? _TypeForwardingDefinition
    return definition
  }
}

//MARK: - KeyDefinitionPair

typealias KeyDefinitionPair = (key: DefinitionKey, definition: _Definition)

/// Definitions are matched if they are registered for the same tag and thier factories accept the same number of runtime arguments.
private func ~=(lhs: KeyDefinitionPair, rhs: KeyDefinitionPair) -> Bool {
  guard lhs.key.type == rhs.key.type else { return false }
  guard lhs.key.tag == rhs.key.tag else { return false }
  guard lhs.definition.numberOfArguments == rhs.definition.numberOfArguments else { return false }
  return true
}

/// Returns key-defintion pairs with definitions able to resolve that type (directly or via type forwarding)
/// and which tag matches provided key's tag or is nil.
/// In the end filters defintions by type of runtime arguments.
func filter(definitions _definitions: [KeyDefinitionPair], byKey key: DefinitionKey, byTypeOfArguments: Bool = false) -> [KeyDefinitionPair] {
  let definitions = _definitions
    .filter({ $0.key.type == key.type || $0.definition.doesImplements(type: key.type) })
    .filter({ $0.key.tag == key.tag || $0.key.tag == nil })
  if byTypeOfArguments {
    return definitions.filter({ $0.key.typeOfArguments == key.typeOfArguments })
  }
  else {
    return definitions
  }
}

/// Orders key-definition pairs putting first definitions registered for provided tag.
func order(definitions _definitions: [KeyDefinitionPair], byTag tag: DependencyContainer.Tag?) -> [KeyDefinitionPair] {
  return
    _definitions.filter({ $0.key.tag == tag }) +
      _definitions.filter({ $0.key.tag != tag })
}
