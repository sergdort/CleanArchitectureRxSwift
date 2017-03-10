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
     Resolve an instance of type `T`.
     
     If no matching definition was registered with provided `tag`,
     container will lookup definition associated with `nil` tag.
     
     - parameter tag: The arbitrary tag to use to lookup definition.
     
     - throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`, `DipError.InvalidType`
     
     - returns: An instance of type `T`.
     
     **Example**:
     ```swift
     let service = try! container.resolve() as Service
     let service = try! container.resolve(tag: "service") as Service
     let service: Service = try! container.resolve()
     ```
     
     - seealso: `register(_:type:tag:factory:)`
     */
    public func resolve<T>(tag tag: DependencyTagConvertible? = nil) throws -> T {
      return try resolve(tag: tag) { factory in try factory() }
    }
    
    /**
     Resolve an instance of requested type. Weakly-typed alternative of `resolve(tag:)`
     
     - warning: This method does not make any type checks, so there is no guaranty that
                resulting instance is actually an instance of requested type.
                That can happen if you register forwarded type that is not implemented by resolved instance.
     
     - parameters:
        - type: Type to resolve
        - tag: The arbitrary tag to use to lookup definition.
     
     - throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`, `DipError.InvalidType`
     
     - returns: An instance of requested type.
     
     **Example**:
     ```swift
     let service = try! container.resolve(Service.self) as! Service
     let service = try! container.resolve(Service.self, tag: "service") as! Service
     ```
     
     - seealso: `resolve(tag:)`, `register(_:type:tag:factory:)`
     */
    public func resolve(type: Any.Type, tag: DependencyTagConvertible? = nil) throws -> Any {
      return try resolve(type, tag: tag) { factory in try factory() }
    }
    
    /**
     Resolve an instance of type `T` using generic builder closure that accepts generic factory and returns created instance.
     
     - parameters:
        - tag: The arbitrary tag to use to lookup definition.
        - builder: Generic closure that accepts generic factory and returns inctance created by that factory.
     
     - throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`, `DipError.InvalidType`
     
     - returns: An instance of type `T`.
     
     - note: You _should not_ call this method directly, instead call any of other
             `resolve(tag:)` or `resolve(tag:withArguments:)` methods.
             You _should_ use this method only to resolve dependency with more runtime arguments than
             _Dip_ supports (currently it's up to six) like in the following example:
     
     ```swift
     public func resolve<T, A, B, C, ...>(tag: Tag? = nil, _ arg1: A, _ arg2: B, _ arg3: C, ...) throws -> T {
       return try resolve(tag: tag) { factory in factory(arg1, arg2, arg3, ...) }
     }
     ```
     
     Though before you do so you should probably review your design and try to reduce the number of dependencies.
     */
    public func resolve<T, U>(tag tag: DependencyTagConvertible? = nil, builder: ((U) throws -> T) throws -> T) throws -> T {
      return try _resolve(tag: tag, builder: builder)
    }
    
    /**
     Resolve an instance of provided type using builder closure. Weakly-typed alternative of `resolve(tag:builder:)`
     
     - seealso: `resolve(tag:builder:)`
     */
    public func resolve<U>(type: Any.Type, tag: DependencyTagConvertible? = nil, builder: ((U) throws -> Any) throws -> Any) throws -> Any {
      return try _resolve(type: type, tag: tag, builder: builder)
    }
  
  }
  
  /// Resolvable protocol provides some extension points for resolving dependencies with property injection.
  public protocol Resolvable {
    /// This method will be called right after instance is created by the container.
    func resolveDependencies(container: DependencyContainer)
    /// This method will be called when all dependencies of the instance are resolved.
    /// When resolving objects graph the last resolved instance will receive this callback first.
    func didResolveDependencies()
  }

  extension Resolvable {
    func resolveDependencies(container: DependencyContainer) {}
    func didResolveDependencies() {}
  }

#endif


