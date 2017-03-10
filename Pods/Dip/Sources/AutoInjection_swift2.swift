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
  extension Injected {
    
    /**
     Creates a new wrapper for auto-injected property.
     
     - parameters:
        - required: Defines if the property is required or not.
                    If container fails to inject required property it will als fail to resolve
                    the instance that defines that property. Default is `true`.
        - tag: An optional tag to use to lookup definitions when injecting this property. Default is `nil`.
        - didInject: block that will be called when concrete instance is injected in this property.
                     Similar to `didSet` property observer. Default value does nothing.
     */
    public convenience init(required: Bool = true, didInject: (T) -> () = { _ in }) {
      self.init(value: nil, required: required, tag: nil, overrideTag: false, didInject: didInject)
    }
    
    public convenience init(required: Bool = true, tag: DependencyTagConvertible?, didInject: (T) -> () = { _ in }) {
      self.init(value: nil, required: required, tag: tag, overrideTag: true, didInject: didInject)
    }
    
    
    public func resolve(container: DependencyContainer) throws {
      let resolved: T? = try super.resolve(with: container)
      value = resolved
    }
  
    /// Returns a new wrapper with provided value.
    public func setValue(value: T?) -> Injected {
      guard (required && value != nil) || !required else {
        fatalError("Can not set required property to nil.")
      }
      return Injected(value: value, required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
    }

  }
  
  extension InjectedWeak {
    
    /**
     Creates a new wrapper for weak auto-injected property.
     
     - parameters:
        - required: Defines if the property is required or not.
                    If container fails to inject required property it will als fail to resolve
                    the instance that defines that property. Default is `true`.
        - tag: An optional tag to use to lookup definitions when injecting this property. Default is `nil`.
        - didInject: block that will be called when concrete instance is injected in this property.
                     Similar to `didSet` property observer. Default value does nothing.
     */
    public convenience init(required: Bool = true, didInject: (T) -> () = { _ in }) {
      self.init(value: nil, required: required, tag: nil, overrideTag: false, didInject: didInject)
    }
    
    public convenience init(required: Bool = true, tag: DependencyTagConvertible?, didInject: (T) -> () = { _ in }) {
      self.init(value: nil, required: required, tag: tag, overrideTag: true, didInject: didInject)
    }
    
    public func resolve(container: DependencyContainer) throws {
      let resolved: T? = try super.resolve(with: container)
      valueBox = resolved.map(WeakBox.init)
    }
  
    /// Returns a new wrapper with provided value.
    public func setValue(value: T?) -> InjectedWeak {
      guard (required && value != nil) || !required else {
        fatalError("Can not set required property to nil.")
      }
      return InjectedWeak(value: value, required: required, tag: tag, overrideTag: overrideTag, didInject: didInject)
    }

  }
#endif
