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

protocol TypeForwardingDefinition: DefinitionType {
  var implementingTypes: [Any.Type] { get }
  func doesImplements(type aType: Any.Type) -> Bool
}

#if swift(>=3.0)
  
extension Definition {
  
  /**
   Registers definition for passed type.
   
   If instance created by factory of definition on which method is called 
   does not implement type passed in a `type` parameter,
   container will throw `DipError.DefinitionNotFound` error when trying to resolve that type.
   
   - parameters:
      - type: Type to register definition for
      - tag: Optional tag to associate definition with. Default is `nil`.
   
   - returns: definition on which `implements` was called
   */
  @discardableResult public func implements<F>(_ type: F.Type, tag: DependencyTagConvertible? = nil) -> Definition {
    precondition(container != nil, "Definition should be registered in the container.")

    container!.register(self, type: type, tag: tag)
    return self
  }
  
  /**
   Registers definition for passed type.
   
   If instance created by factory of definition on which method is called
   does not implement type passed in a `type` parameter,
   container will throw `DipError.DefinitionNotFound` error when trying to resolve that type.
   
   - parameters:
      - type: Type to register definition for
      - tag: Optional tag to associate definition with. Default is `nil`.
      - resolvingProperties: Optional block to be called to resolve instance property dependencies
   
   - returns: definition on which `implements` was called
   */
  @discardableResult public func implements<F>(_ type: F.Type, tag: DependencyTagConvertible? = nil, resolvingProperties: @escaping (DependencyContainer, F) throws -> ()) -> Definition {
    precondition(container != nil, "Definition should be registered in the container.")

    let forwardDefinition = container!.register(self, type: type, tag: tag)
    forwardDefinition.resolvingProperties(resolvingProperties)
    return self
  }

  ///Registers definition for types passed as parameters
  @discardableResult public func implements<A, B>(_ a: A.Type, _ b: B.Type) -> Definition {
    return implements(a).implements(b)
  }

  ///Registers definition for types passed as parameters
  @discardableResult public func implements<A, B, C>(_ a: A.Type, _ b: B.Type, _ c: C.Type) -> Definition {
    return implements(a).implements(b).implements(c)
  }

  ///Registers definition for types passed as parameters
  @discardableResult public func implements<A, B, C, D>(_ a: A.Type, _ b: B.Type, c: C.Type, d: D.Type) -> Definition {
    return implements(a).implements(b).implements(c).implements(d)
  }
  
}

#endif

extension DependencyContainer {
  
  func _register<T, U, F>(definition aDefinition: Definition<T, U>, type: F.Type, tag: DependencyTagConvertible? = nil) -> Definition<F, U> {
    let definition = aDefinition
    precondition(definition.container === self, "Definition should be registered in the container.")
    
    let key = DefinitionKey(type: F.self, typeOfArguments: U.self)
    
    let forwardDefinition = DefinitionBuilder<F, U> {
      $0.scope = definition.scope
      
      let factory = definition.factory
      $0.factory = { [unowned self] in
        let resolved = try factory($0)
        if let resolved = resolved as? F {
          return resolved
        }
        else {
          throw DipError.invalidType(resolved: resolved, key: key.tagged(with: self.context.tag))
        }
      }

      $0.numberOfArguments = definition.numberOfArguments
      $0.autoWiringFactory = definition.autoWiringFactory.map({ factory in
        { [unowned self] in
          let resolved = try factory($0, $1)
          if let resolved = resolved as? F {
            return resolved
          }
          else {
            throw DipError.invalidType(resolved: resolved, key: key.tagged(with: self.context.tag))
          }
        }
      })
      $0.forwardsTo = definition
      }.build()
    
    register(forwardDefinition, tag: tag)
    return forwardDefinition
  }
  
  /// Searches for definition that forwards requested type
  func typeForwardingDefinition(forKey key: DefinitionKey) -> KeyDefinitionPair? {
    var forwardingDefinitions = self.definitions.map({ (key: $0.0, definition: $0.1) })
    
    forwardingDefinitions = filter(definitions: forwardingDefinitions, byKey: key, byTypeOfArguments: true)
    forwardingDefinitions = order(definitions: forwardingDefinitions, byTag: key.tag)

    //we need to carry on original tag
    return forwardingDefinitions.first.map({ ($0.key.tagged(with: key.tag), $0.definition) })
  }
  
}
