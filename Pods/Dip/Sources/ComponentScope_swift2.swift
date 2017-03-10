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

  ///Component scope defines a strategy used by the `DependencyContainer` to manage resolved instances life cycle.
  public enum ComponentScope {
    
    /**
     A new instance will be created every time it's resolved.
     This is a default strategy. Use this strategy when you don't want instances to be shared
     between different consumers (i.e. if it is not thread safe).
     
     **Example**:
     
     ```
     container.register { ServiceImp() as Service }
     container.register {
       ServiceConsumerImp(
         service1: try container.resolve() as Service
         service2: try container.resolve() as Service
         ) as ServiceConsumer
       }
     let consumer = container.resolve() as ServiceConsumer
     consumer.service1 !== consumer.service2 //true
     
     ```
     */
    case Unique
    
    /**
     Instance resolved with the same definition will be reused until topmost `resolve(tag:)` method returns.
     When you resolve the same object graph again the container will create new instances.
     Use this strategy if you want different object in objects graph to share the same instance.
     
     - warning: Make sure this component is thread safe or accessed always from the same thread.
     
     **Example**:
     
     ```
     container.register { ServiceImp() as Service }
     container.register {
       ServiceConsumerImp(
         service1: try container.resolve() as Service
         service2: try container.resolve() as Service
       ) as ServiceConsumer
     }
     let consumer1 = container.resolve() as ServiceConsumer
     let consumer2 = container.resolve() as ServiceConsumer
     consumer1.service1 === consumer1.service2 //true
     consumer2.service1 === consumer2.service2 //true
     consumer1.service1 !== consumer2.service1 //true
     ```
     */
    case Shared
    
    /**
     Resolved instance will be retained by the container and always reused.
     Do not mix this life cycle with _singleton pattern_.
     Instance will be not shared between different containers unless they collaborate.
     
     - warning: Make sure this component is thread safe or accessed always from the same thread.
     
     - note: When you override or remove definition from the container an instance
             that was resolved with this definition will be released. When you reset
             the container it will release all singleton instances.
     
     **Example**:
     
     ```
     container.register(.singleton) { ServiceImp() as Service }
     container.register {
       ServiceConsumerImp(
         service1: try container.resolve() as Service
         service2: try container.resolve() as Service
       ) as ServiceConsumer
     }
     let consumer1 = container.resolve() as ServiceConsumer
     let consumer2 = container.resolve() as ServiceConsumer
     consumer1.service1 === consumer1.service2 //true
     consumer2.service1 === consumer2.service2 //true
     consumer1.service1 === consumer2.service1 //true
     ```
     */
    case Singleton
    
    /**
     The same scope as a `Singleton`, but instance will be created when container is bootstrapped.
     
     - seealso: `bootstrap()`
     */
    case EagerSingleton
    
    /**
     The same scope as a `Singleton`, but container stores week reference to the resolved instance.
     While a strong reference to the resolved instance exists resolve will return the same instance.
     After the resolved instance is deallocated next resolve will produce a new instance.
     */
    case WeakSingleton
  
    static var unique: ComponentScope { return .Unique }
    static var shared: ComponentScope { return .Shared }
    static var singleton: ComponentScope { return .Singleton }
    static var weakSingleton: ComponentScope { return .WeakSingleton }
    static var eagerSingleton: ComponentScope { return .EagerSingleton }
  }

#endif
