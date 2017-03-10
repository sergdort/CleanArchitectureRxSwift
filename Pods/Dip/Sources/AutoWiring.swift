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

protocol AutoWiringDefinition: DefinitionType {
  var numberOfArguments: Int { get }
  var autoWiringFactory: ((DependencyContainer, DependencyContainer.Tag?) throws -> Any)? { get }
}

extension DependencyContainer {
  
  /// Tries to resolve instance using auto-wiring
  func autowire<T>(key aKey: DefinitionKey) throws -> T {
    let key = aKey
    guard key.typeOfArguments == Void.self else {
      throw DipError.definitionNotFound(key: key)
    }
    
    let autoWiringKey = try autoWiringDefinition(byKey: key).key
    
    do {
      let key = autoWiringKey.tagged(with: key.tag ?? context.tag)
      return try _resolve(key: key) { definition in
        try definition.autoWiringFactory!(self, key.tag) as! T
      }
    }
    catch {
      throw DipError.autoWiringFailed(type: key.type, underlyingError: error)
    }
  }

  private func autoWiringDefinition(byKey key: DefinitionKey) throws -> KeyDefinitionPair {
    var definitions = self.definitions.map({ (key: $0.0, definition: $0.1) })
    
    definitions = filter(definitions: definitions, byKey: key)
    definitions = definitions.sorted(by: { $0.definition.numberOfArguments > $1.definition.numberOfArguments })

    guard definitions.count > 0 && definitions[0].definition.numberOfArguments > 0 else {
      throw DipError.definitionNotFound(key: key)
    }
    
    let maximumNumberOfArguments = definitions.first?.definition.numberOfArguments
    definitions = definitions.filter({ $0.definition.numberOfArguments == maximumNumberOfArguments })
    definitions = order(definitions: definitions, byTag: key.tag)

    //when there are several definitions with the same number of arguments but different arguments types
    if definitions.count > 1 && definitions[0].key.typeOfArguments != definitions[1].key.typeOfArguments {
      let error = DipError.ambiguousDefinitions(type: key.type, definitions: definitions.map({ $0.definition }))
      throw DipError.autoWiringFailed(type: key.type, underlyingError: error)
    } else {
      return definitions[0]
    }
  }
  
}
