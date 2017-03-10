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
     Registers definition for passed type.
     
     If instance created by factory of definition, passed as a first parameter,
     does not implement type passed in a `type` parameter,
     container will throw `DipError.DefinitionNotFound` error when trying to resolve that type.
     
     - parameters:
        - definition: Definition to register
        - type: Type to register definition for
        - tag: Optional tag to associate definition with. Default is `nil`.
     
     - returns: New definition registered for passed type.
     */
    public func register<T, U, F>(definition: Definition<T, U>, type: F.Type, tag: DependencyTagConvertible? = nil) -> Definition<F, U> {
      return _register(definition: definition, type: type, tag: tag)
    }
    
    /**
     Register definiton in the container and associate it with an optional tag.
     Will override already registered definition for the same type and factory, associated with the same tag.
     
     - parameters:
        - tag: The arbitrary tag to associate this definition with. Pass `nil` to associate with any tag. Default value is `nil`.
        - definition: The definition to register in the container.
     
     */
    public func register<T, U>(definition: Definition<T, U>, tag: DependencyTagConvertible? = nil) {
      _register(definition: definition, tag: tag)
    }
  }
#endif

