<p align="center">
  <img src="https://raw.githubusercontent.com/delba/JASON/assets/JASON.png">
</p>

<p align="center">
    <a href="https://travis-ci.org/delba/JASON"><img alt="Travis Status" src="https://img.shields.io/travis/delba/JASON.svg"/></a>
    <a href="https://img.shields.io/cocoapods/v/JASON.svg"><img alt="CocoaPods compatible" src="https://img.shields.io/cocoapods/v/JASON.svg"/></a>
    <a href="https://github.com/Carthage/Carthage"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
    <a href="https://img.shields.io/cocoapods/p/JASON.svg"><img alt="Platform" src="https://img.shields.io/cocoapods/p/JASON.svg"/></a>
</p>

**JASON** is a [faster](https://github.com/delba/JASON/tree/benchmarks) `JSON` deserializer written in Swift.

```md
JASON is the best framework we found to manage JSON at Swapcard. This is by far the fastest and
the most convenient out there, it made our code clearer and improved the global performance
of the app when dealing with large amount of data.
```
> *[Gautier Gédoux](https://github.com/gautier-gdx), lead iOS developer at [Swapcard](https://www.swapcard.com/)*

<p align="center">
<a href="#features">Features</a> • <a href="#usage">Usage</a> • <a href="#example">Example</a> • <a href="#references">References</a> • <a href="#installation">Installation</a> • <a href="#license">License</a>
</p>

## Features

- [x] Very fast - [`benchmarks`](https://github.com/delba/JASON/tree/benchmarks)
- [x] Fully tested
- [x] Fully documented
<p></p>
- [x] Clean code
- [x] Beautiful API
- [x] Regular updates
<p></p>
- [x] Support for iOS, OSX, tvOS, watchOS
- [x] Compatible with [Carthage](https://github.com/delba/JASON#carthage) / [CocoaPods](https://github.com/delba/JASON#cocoapods)
- [x] Provide extensions - [`Extensions/`](https://github.com/delba/JASON/tree/master/Extensions)

## Usage

#### Initialization

```swift
let json = JSON(anything) // where `anything` is `AnyObject?`
```

If you're using [`Alamofire`](https://github.com/Alamofire/Alamofire), include [`JASON+Alamofire.swift`](https://github.com/delba/JASON/blob/master/Extensions/JASON%2BAlamofire.swift) in your project for even more awesomeness:

```swift
Alamofire.request(.GET, peopleURL).responseJASON { response in
    if let json = response.result.value {
        let people = json.map(Person.init)
        print("people: \(people)")
    }
}
```

If you're using [`Moya`](https://github.com/Moya/Moya), check out [`Moya-JASON`](https://github.com/DroidsOnRoids/Moya-JASON)!

#### Parsing

Use subscripts to parse the `JSON` object:

```swift
json["people"][0]["name"]

// Or with a path:

json[path: "people", 0, "name"]
```

#### Type casting

Cast `JSON` value to its appropriate type by using the computed property `json.<type>`:

```swift
let name = json["name"].string // the name as String?
```

The non-optional variant `json.<type>Value` will return a default value if not present/convertible:

```swift
let name = json["wrong"].stringValue // the name will be ""
```

You can also access the internal value as `AnyObject?` if you want to cast it yourself:

```swift
let something = json["something"].object
```

*See the [References section](https://github.com/delba/JASON#references) for the full list of properties.*

#### `JSONKey`:

> This idea is stolen from [`SwiftyUserDefaults`](https://github.com/radex/SwiftyUserDefaults) by **Radek Pietruszewski** ([GitHub](https://github.com/radex), [Twitter](https://twitter.com/radexp), [Blog](http://radex.io)).
<br/>
> I can't recommend enough to read his article about it! :boom: [Statically-typed NSUserDefaults](http://radex.io/swift/nsuserdefaults/static/) :boom:

Define and use your `JSONKey` as follow:

```swift
// With a int key:

let personKey = JSONKey<JSON>(0)
let personJSON = peopleJSON[personKey]

// With a string key:

let nameKey = JSONKey<String>("name")
let name = personJSON[nameKey]

// With a path:

let twitterURLKey = JSONKey<NSURL?>(path: 0, "twitter")
let twitterURL = peopleJSON[twitterURLKey]
```

You might find more convenient to extend `JSONKeys` as shown in the [Example section](https://github.com/delba/JASON#example).

*See the [References section](https://github.com/delba/JASON#references) for the full list of `JSONKey` types.*

#### Third-party libraries:

- [DroidsOnRoids/**Moya-JASON**](https://github.com/DroidsOnRoids/Moya-JASON) JASON bindings for Moya.

## Example

> This example uses the **Dribbble API** ([docs](http://developer.dribbble.com/v1/)).
<br/>
> An example of the server response can be found in [`Tests/Supporting Files/shots.json`](https://github.com/delba/JASON/blob/master/Tests/Supporting%20Files/shots.json)

- **Step 1:** Extend `JSONKeys` to define your `JSONKey`

```swift
JSON.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

extension JSONKeys {
    static let id    = JSONKey<Int>("id")
    static let createdAt = JSONKey<NSDate?>("created_at")
    static let updatedAt = JSONKey<NSDate?>("updated_at")
    
    static let title = JSONKey<String>("title")
    
    static let normalImageURL = JSONKey<NSURL?>(path: "images", "normal")
    static let hidpiImageURL  = JSONKey<NSURL?>(path: "images", "hidpi")
    
    static let user = JSONKey<JSON>("user")
    static let name = JSONKey<String>("name") 
}
```

- **Step 2:** Create the `Shot` and `User` models

```swift
struct Shot {
    let id: Int
    let title: String
    
    let normalImageURL: NSURL
    var hidpiImageURL: NSURL?
    
    let createdAt: NSDate
    let updatedAt: NSDate
    
    let user: User

    init(_ json: JSON) {
        id    = json[.id]
        title = json[.title]
        
        normalImageURL = json[.normalImageURL]!
        hidpiImageURL  = json[.hidpiImageURL]
        
        createdAt = json[.createdAt]!
        updatedAt = json[.updatedAt]!
        
        user = User(json[.user])
    }
}
```

```swift
struct User {
    let id: Int
    let name: String
    
    let createdAt: NSDate
    let updatedAt: NSDate

    init(_ json: JSON) {
        id   = json[.id]
        name = json[.name]
        
        createdAt = json[.createdAt]!
        updatedAt = json[.updatedAt]!
    }
}
```

- **Step 3:** Use the [`JASON+Alamofire.swift`](https://github.com/delba/JASON/blob/master/Extensions/JASON%2BAlamofire.swift) extension to fetch the shots

```swift
Alamofire.request(.GET, shotsURL).responseJASON { response in
    if let json = response.result.value {
        let shots = json.map(Shot.init)
    }
}
```

## References

> Include [`JASON+Properties.swift`](https://github.com/delba/JASON/blob/master/Extensions/JASON%2BProperties.swift) for even more types!

Property              | JSONKey Type           | Default value
--------------------- | ---------------------- | -------------
`string`              | `String?`              |
`stringValue`         | `String`               | `""`
`int`                 | `Int?`                 |
`intValue`            | `Int`                  | `0`
`double`              | `Double?`              |
`doubleValue`         | `Double`               | `0.0`
`float`               | `Float?`               |
`floatValue`          | `Float`                | `0.0`
`nsNumber`            | `NSNumber?`            |
`nsNumberValue`       | `NSNumber`             | `0`
`cgFloat`             | `CGFloat?`             |
`cgFloatValue`        | `CGFloat`              | `0.0`
`bool`                | `Bool?`                |
`boolValue`           | `Bool`                 | `false`
`nsDate`              | `NSDate?`              |
`nsURL`               | `NSURL?`               |
`dictionary`          | `[String: AnyObject]?` |
`dictionaryValue`     | `[String: AnyObject]`  | `[:]`
`jsonDictionary`      | `[String: JSON]?`      |
`jsonDictionaryValue` | `[String: JSON]`       | `[:]`
`nsDictionary`        | `NSDictionary?`        |
`nsDictionaryValue`   | `NSDictionary`         | `NSDictionary()`
`array`               | `[AnyObject]?`         |
`arrayValue`          | `[AnyObject]`          | `[]`
`jsonArray`           | `[JSON]?`              |
`jsonArrayValue`      | `[JSON]`               | `[]`
`nsArray`             | `NSArray?`             |
`nsArrayValue`        | `NSArray`              | `NSArray()`

> Configure JSON.dateFormatter if needed for `nsDate` parsing

## Installation

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate **`JASON`** into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "delba/JASON" >= 3.0
```

#### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate **`JASON`** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

pod 'JASON', '~> 3.0'
```

## License

Copyright (c) 2015-2016 Damien (http://delba.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
