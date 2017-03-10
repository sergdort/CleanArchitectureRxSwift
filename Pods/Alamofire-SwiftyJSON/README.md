#Alamofire-SwiftyJSON ![](https://travis-ci.org/SwiftyJSON/Alamofire-SwiftyJSON.svg?branch=master)

An extension to make serializing [Alamofire](https://github.com/Alamofire/Alamofire)'s response with [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) easily.

## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 8.0

## Install

```ruby
pod 'Alamofire-SwiftyJSON'
```

## Usage

```swift
Alamofire.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.default)
         .responseSwiftyJSON { dataResponse in
                     print(dataResponse.request)
                     print(dataResponse.response)
                     print(dataResponse.error)
                     print(dataResponse.value)
                  })
```
