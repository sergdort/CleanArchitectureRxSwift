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

/**
 Errors thrown by `DependencyContainer`'s methods.
 
 - seealso: `resolve(tag:)`
 */
public enum DipError: Error, CustomStringConvertible {
  
  /**
   Thrown by `resolve(tag:)` if no matching definition was registered in container.
   
   - parameter key: definition key used to lookup matching definition
   */
  case DefinitionNotFound(key: DefinitionKey)
  
  /**
   Thrown by `resolve(tag:)` if failed to auto-inject required property.
   
   - parameters:
      - label: The name of the property
      - type: The type of the property
      - underlyingError: The error that caused auto-injection to fail
   */
  case AutoInjectionFailed(label: String?, type: Any.Type, underlyingError: Error)
  
  /**
   Thrown by `resolve(tag:)` if failed to auto-wire a type.
   
   - parameters:
      - type: The type that failed to be resolved by auto-wiring
      - underlyingError: The error that cause auto-wiring to fail
   */
  case AutoWiringFailed(type: Any.Type, underlyingError: Error)
  
  /**
   Thrown when auto-wiring type if several definitions with the same number of runtime arguments
   are registered for that type.
   
   - parameters:
      - type: The type that failed to be resolved by auto-wiring
      - definitions: Ambiguous definitions
   */
  case AmbiguousDefinitions(type: Any.Type, definitions: [DefinitionType])
  
  /**
   Thrown by `resolve(tag:)` if resolved instance does not implemenet resolved type (i.e. when type-forwarding).
   
   - parameters:
      - resolved: Resolved instance
      - key: Definition key used to resolve instance
   */
  case InvalidType(resolved: Any?, key: DefinitionKey)
  
  public var description: String {
    switch self {
    case let .DefinitionNotFound(key):
      return "No definition registered for \(key).\nCheck the tag, type you try to resolve, number, order and types of runtime arguments passed to `resolve()` and match them with registered factories for type \(key.type)."
    case let .AutoInjectionFailed(label, type, error):
      return "Failed to auto-inject property \"\(label.desc)\" of type \(type). \(error)"
    case let .AutoWiringFailed(type, error):
      return "Failed to auto-wire type \"\(type)\". \(error)"
    case let .AmbiguousDefinitions(type, definitions):
      return "Ambiguous definitions for \(type):\n" +
        definitions.map({ "\($0)" }).joined(separator: ";\n")
    case let .InvalidType(resolved, key):
      return "Resolved instance \(resolved ?? "nil") does not implement expected type \(key.type)."
    }
  }

  static func definitionNotFound(key aKey: DefinitionKey) -> DipError {
    return DipError.DefinitionNotFound(key: aKey)
  }
  
  static func autoInjectionFailed(label aLabel: String?, type: Any.Type, underlyingError: Error) -> DipError {
    return DipError.AutoInjectionFailed(label: aLabel, type: type, underlyingError: underlyingError)
  }
  
  static func autoWiringFailed(type aType: Any.Type, underlyingError: Error) -> DipError {
    return DipError.AutoWiringFailed(type: aType, underlyingError: underlyingError)
  }
  
  static func ambiguousDefinitions(type aType: Any.Type, definitions: [DefinitionType]) -> DipError {
    return DipError.AmbiguousDefinitions(type: aType, definitions: definitions)
  }
  
  static func invalidType(resolved _resolved: Any?, key: DefinitionKey) -> DipError {
    return DipError.InvalidType(resolved: _resolved, key: key)
  }
}
#endif

