# Dip

[![CI Status](https://travis-ci.org/AliSoftware/Dip.svg?branch=develop)](https://travis-ci.org/AliSoftware/Dip)
[![Version](https://img.shields.io/cocoapods/v/Dip.svg?style=flat)](http://cocoapods.org/pods/Dip)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Dip.svg?style=flat)](http://cocoapods.org/pods/Dip)
[![Platform](https://img.shields.io/cocoapods/p/Dip.svg?style=flat)](http://cocoapods.org/pods/Dip)
[![Swift Version](https://img.shields.io/badge/Swift-2.3--3.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Version](https://img.shields.io/badge/Linux-3.0--RELEASE-4BC51D.svg?style=flat)](https://developer.apple.com/swift)

![Animated Dipping GIF](cinnamon-pretzels-caramel-dipping.gif)  
_Photo courtesy of [www.kevinandamanda.com](http://www.kevinandamanda.com/recipes/appetizer/homemade-soft-cinnamon-sugar-pretzel-bites-with-salted-caramel-dipping-sauce.html)_

## Introduction

`Dip` is a simple **Dependency Injection Container**.

It's aimed to be as simple as possible yet provide rich functionality usual for DI containers on other platforms. It's inspired by `.NET`'s [Unity Container](https://msdn.microsoft.com/library/ff647202.aspx) and other DI containers.

* You start by creating `let container = DependencyContainer()` and **registering your dependencies, by associating a _protocol_ or _type_ to a `factory`** using `container.register { MyService() as Service }`.
* Then you can call `container.resolve() as Service` to **resolve an instance of _protocol_ or _type_** using that `DependencyContainer`.
* You can easily use Dip along with **Storyboards and Nibs** - checkout **[Dip-UI](https://github.com/AliSoftware/Dip-UI)** extensions. There is also a **[code generator](https://github.com/ilyapuchka/dipgen)** that can help to simplify registering new components.

<details>
<summary>Basic usage</summary>

```swift
import Dip

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Create the container
    private let container = DependencyContainer { container in
    
        // Register some factory. ServiceImp here implements protocol Service
        container.register { ServiceImp() as Service }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool { 
        
        // Resolve a concrete instance. Container will instantiate new instance of ServiceImp
        let service = try! container.resolve() as Service
    
        ...
    }
}

```

</details>

<details>
<summary>More sophisticated example</summary>

```swift
import Dip

class AppDelegate: UIResponder, UIApplicationDelegate {
	private let container = DependencyContainer.configure()
	...
}

//CompositionRoot.swift
import Dip
import DipUI

extension DependencyContainer {

	static func configure() -> DependencyContainer {
		return DependencyContainer { container in 
			unowned let container = container
			DependencyContainer.uiContainers = [container]
		
			container.register(tag: "ViewController") { ViewController() }
			  .resolvingProperties { container, controller in
				  controller.animationsFactory = try container.resolve() as AnimatonsFactory
			}
    
			container.register { AuthFormBehaviourImp(apiClient: $0) as AuthFormBehaviour }
			container.register { container as AnimationsFactory }
			container.register { view in ShakeAnimationImp(view: view) as ShakeAnimation }
			container.register { APIClient(baseURL: NSURL(string: "http://localhost:2368")!) as ApiClient }
		}
	}

}

extension DependencyContainer: AnimationsFactory { 
    func shakeAnimation(view: UIView) -> ShakeAnimation {
        return try! self.resolve(withArguments: view)
    }
}

extension ViewController: StoryboardInstantiatable {}

//ViewController.swift

class ViewController {
    var animationsFactory: AnimationsFactory?

    private let _formBehaviour = Injected<AuthFormBehaviour>()
    
    var formBehaviour: AuthFormBehaviour? {
        return _formBehaviour.value
    }
	...
}

```

</details>

## Documentation & Usage Examples

Dip is completely [documented](http://cocoadocs.org/docsets/Dip/5.0.0/) and comes with a Playground that lets you try all its features and become familiar with API. You can find it in `Dip.xcworkspace`.

> Note: it may happen that you will need to build Dip framework before playground will be able to use it. For that select `Dip` scheme and build for iPhone Simulator.

You can find bunch of usage examples and usfull tips in a [wiki](../../wiki). 

If your are using [VIPER](https://www.objc.io/issues/13-architecture/viper/) architecture - [here](https://github.com/ilyapuchka/VIPER-SWIFT) is VIPER demo app that uses Dip instead of manual dependency injection.

There are also several blog posts that describe how to use Dip and some of its implementation details:

- [IoC container in Swift](http://ilya.puchka.me/ioc-container-in-swift/)
- [IoC container in Swift. Circular dependencies and auto-injection](http://ilya.puchka.me/ioc-container-in-swift-circular-dependencies-and-auto-injection/)
- [Dependency injection with Dip](http://ilya.puchka.me/dependency-injecinjection-with-dip/)

File an issue if you have any question. Pull requests are warmly welcome too.


## Features

- **[Scopes](../../wiki/scopes)**. Dip supports 5 different scopes (or life cycle strategies): _Unique_, _Shared_, _Singleton_, _EagerSingleton_, _WeakSingleton_;
- **[Auto-wiring](../../wiki/auto-wiring)** & **[Auto-injection](../../wiki/auto-injection)**. Dip can infer your components' dependencies injected in constructor and automatically resolve them as well as dependencies injected with properties.
- **[Resolving optionals](../../wiki/resolving-optionals)**. Dip is able to resolve constructor or property dependencies defined as optionals.
- **[Type forwarding](../../wiki/type-forwarding)**. You can register the same factory to resolve different types implemeted by a single class.
- **[Circular dependencies](../../wiki/circular-dependencies)**. Dip will be able to resolve circular dependencies if you will follow some simple rules;
- **[Storyboards integration](../../wiki/storyboards-integration)**. You can easily use Dip along with storyboards and Xibs without ever referencing container in your view controller's code;
- **[Named definitions](../../wiki/named-definitions)**. You can register different factories for the same protocol or type by registering them with [tags]();
- **[Runtime arguments](../../wiki/runtime-arguments)**. You can register factories that accept up to 6 runtime arguments (and extend it if you need);
- **[Easy configuration](../../wiki/containers-collaboration)** & **Code generation**. No complex containers hierarchy, no unneeded functionality. Tired of writing all registrations by hand? There is a [cool code generator](https://github.com/ilyapuchka/dipgen) that will create them for you. The only thing you need is to annotate your code with some comments.
- **Weakly typed components**. Dip can resolve "weak" types when they are unknown at compile time.
- **Thread safety**. Registering and resolving components is thread safe;
- **Helpful error messages and configuration validation**. You can validate your container configuration. If something can not be resolved at runtime Dip throws an error that completely describes the issue;


## Installation

Since version 5.0.0 Dip is built with Swift 3.0. You can install Dip using your favorite dependency manager:

<details>
<summary>CocoaPods</summary>

`pod "Dip"`

To build for Swift 2.3 add this code to the bottom of your Podfile

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
```

> You need at least 1.1.0.rc.2 version of CocoaPods.

</details>

<details>
<summary>Carthage</summary>

```
github "AliSoftware/Dip"
```

To build for Swift 2.3 run Carthage with `--toolchain com.apple.dt.toolchain.Swift_2_3` option.

</details>

<details>
<summary>Swift Package Manager</summary>

```swift
.Package(url: "https://github.com/AliSoftware/Dip", majorVersion: 5, minor: 0)
```

</details>

## Running tests

On OSX you can run tests from Xcode. On Linux you need to have Swift Package Manager installed and use it to build and run tests using this command: `swift build --clean && swift build && swift test`

## Credits

This library has been created by [**Olivier Halligon**](olivier@halligon.net) and is maintained by [**Ilya Puchka**](https://twitter.com/ilyapuchka).

**Dip** is available under the **MIT license**. See the `LICENSE` file for more info.

The animated GIF at the top of this `README.md` is from [this recipe](http://www.kevinandamanda.com/recipes/appetizer/homemade-soft-cinnamon-sugar-pretzel-bites-with-salted-caramel-dipping-sauce.html) on the yummy blog of [Kevin & Amanda](http://www.kevinandamanda.com/recipes/). Go try the recipe!

The image used as the SampleApp LaunchScreen and Icon is from [Matthew Hine](https://commons.wikimedia.org/wiki/File:Chocolate_con_churros_-_San_Ginés,_Madrid.jpg) and is under _CC-by-2.0_.
