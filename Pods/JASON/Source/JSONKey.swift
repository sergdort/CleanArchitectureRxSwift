//
// JSONKey.swift
//
// Copyright (c) 2015-2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

// MARK: - JSONKey

private enum KeyType {
    case string(Swift.String)
    case int(Swift.Int)
    case path([Any])
}

open class JSONKeys {
    fileprivate init() {}
}

open class JSONKey<ValueType>: JSONKeys {
    fileprivate let type: KeyType
    
    /**
     Creates a new instance of JSONKey.
     
     - parameter key: A string.
     
     - returns: A new instance of JSONKey.
     */
    public init(_ key: String) {
        self.type = .string(key)
    }
    
    /**
     Creates a new instance of JSONKey.
     
     - parameter key: An integer.
     
     - returns: A new instance of JSONKey.
     */
    public init(_ key: Int) {
        self.type = .int(key)
    }
    
    /**
     Creates a new instance of JSONKey.
     
     - parameter key: Any
     
     - returns: A new instance of JSONKey.
     */
    public init(path indexes: Any...) {
        self.type = .path(indexes)
    }
}

private extension JSON {
    subscript(type: KeyType) -> JSON {
        switch type {
        case .string(let key): return self[key]
        case .int(let key): return self[key]
        case .path(let indexes): return self[indexes]
        }
    }
}

// MARK: - JSON

extension JSON {
    /**
     Returns the value associated with the given key as JSON.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as JSON.
     */
    public subscript(key: JSONKey<JSON>) -> JSON {
        return self[key.type]
    }
}

// MARK: - String

extension JSON {
    /**
     Returns the value associated with the given key as a string or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a string or nil if not present/convertible.
     */
    public subscript(key: JSONKey<String?>) -> String? {
        return self[key.type].string
    }
    
    /**
     Returns the value associated with the given key as a string or "" if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a string or "" if not present/convertible.
     */
    public subscript(key: JSONKey<String>) -> String {
        return self[key.type].stringValue
    }
}

// MARK: - Integer

extension JSON {
    /**
     Returns the value associated with the given key as a 64-bit signed integer or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 64-bit signed integer or nil if not present/convertible.
     */
    public subscript(key: JSONKey<Int?>) -> Int? {
        return self[key.type].int
    }
    
    /**
     Returns the value associated with the given key as a 64-bit signed integer or 0 if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 64-bit signed integer or 0 if not present/convertible.
     */
    public subscript(key: JSONKey<Int>) -> Int {
        return self[key.type].intValue
    }
}

// MARK: - FloatingPointType

extension JSON {
    /**
     Returns the value associated with the given key as a 64-bit floating-point number or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 64-bit floating-point number or nil if not present/convertible.
     */
    public subscript(key: JSONKey<Double?>) -> Double? {
        return self[key.type].double
    }
    
    /**
     Returns the value associated with the given key as a 64-bit floating-point number or 0.0 if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 64-bit floating-point number or 0.0 if not present/convertible.
     */
    public subscript(key: JSONKey<Double>) -> Double {
        return self[key.type].doubleValue
    }
    
    /**
     Returns the value associated with the given key as a 32-bit floating-point number or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 32-bit floating-point number or nil if not present/convertible.
     */
    public subscript(key: JSONKey<Float?>) -> Float? {
        return self[key.type].float
    }
    
    /**
     Returns the value associated with the given key as a 32-bit floating-point number or 0.0 if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a 32-bit floating-point number or 0.0 if not present/convertible.
     */
    public subscript(key: JSONKey<Float>) -> Float {
        return self[key.type].floatValue
    }
    
    /**
     Returns the value associated with the given key as a NSNumber or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSNumber or nil if not present/convertible.
     */
    public subscript(key: JSONKey<NSNumber?>) -> NSNumber? {
        return self[key.type].nsNumber
    }
    
    /**
     Returns the value associated with the given key as a NSNumber or 0 if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSNumber or 0 if not present/convertible.
     */
    public subscript(key: JSONKey<NSNumber>) -> NSNumber {
        return self[key.type].nsNumberValue
    }
    
    /**
     Returns the value associated with the given key as a CGFloat or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a CGFloat or nil if not present/convertible.
     */
    public subscript(key: JSONKey<CGFloat?>) -> CGFloat? {
        return self[key.type].cgFloat
    }
    
    /**
     Returns the value associated with the given key as a CGFloat or 0.0 if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a CGFloat or 0.0 if not present/convertible.
     */
    public subscript(key: JSONKey<CGFloat>) -> CGFloat {
        return self[key.type].cgFloatValue
    }
}

// MARK: - Bool

extension JSON {
    /**
     Returns the value associated with the given key as a Bool or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a Bool or nil if not present/convertible.
     */
    public subscript(key: JSONKey<Bool?>) -> Bool? {
        return self[key.type].bool
    }
    
    /**
     Returns the value associated with the given key as a Bool or false if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a Bool or false if not present/convertible.
     */
    public subscript(key: JSONKey<Bool>) -> Bool {
        return self[key.type].boolValue
    }
}

// MARK: - NSDate

extension JSON {
    /**
     Returns the value associated with the given key as a NSDate or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSDate or nil if not present/convertible.
     */
    public subscript(key: JSONKey<Date?>) -> Date? {
        return self[key.type].nsDate
    }
}

// MARK: - NSURL

extension JSON {
    /**
     Returns the value associated with the given key as a NSURL or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSURL or nil if not present/convertible.
     */
    public subscript(key: JSONKey<URL?>) -> URL? {
        return self[key.type].nsURL
    }
}

// MARK: - Dictionary

extension JSON {
    /**
     Returns the value associated with the given key as a dictionary or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a dictionary or nil if not present/convertible.
     */
    public subscript(key: JSONKey<[String: AnyObject]?>) -> [String: AnyObject]? {
        return self[key.type].dictionary
    }
    
    /**
     Returns the value associated with the given key as a dictionary or an empty dictionary if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a dictionary or an empty dictionary if not present/convertible.
     */
    public subscript(key: JSONKey<[String: AnyObject]>) -> [String: AnyObject] {
        return self[key.type].dictionaryValue
    }
    
    /**
     Returns the value associated with the given key as a dictionary or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a dictionary or nil if not present/convertible.
     */
    public subscript(key: JSONKey<[String: JSON]?>) -> [String: JSON]? {
        return self[key.type].jsonDictionary
    }
    
    /**
     Returns the value associated with the given key as a dictionary or an empty dictionary if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a dictionary or an empty dictionary if not present/convertible.
     */
    public subscript(key: JSONKey<[String: JSON]>) -> [String: JSON] {
        return self[key.type].jsonDictionaryValue
    }
    /**
     Returns the value associated with the given key as a dictionary or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a dictionary or nil if not present/convertible.
     */
    public subscript(key: JSONKey<NSDictionary?>) -> NSDictionary? {
        return self[key.type].nsDictionary
    }
    
    /**
     Returns the value associated with the given key as a NSDictionary or an empty NSDictionary if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSDictionary or an empty NSDictionary if not present/convertible.
     */
    public subscript(key: JSONKey<NSDictionary>) -> NSDictionary {
        return self[key.type].nsDictionaryValue
    }
}

// MARK: - Array

extension JSON {
    /**
     Returns the value associated with the given key as an array or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as an array or nil if not present/convertible.
     */
    public subscript(key: JSONKey<[AnyObject]?>) -> [AnyObject]? {
        return self[key.type].array
    }
    
    /**
     Returns the value associated with the given key as an array or an empty array if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as an array or an empty array if not present/convertible.
     */
    public subscript(key: JSONKey<[AnyObject]>) -> [AnyObject] {
        return self[key.type].arrayValue
    }
    
    /**
     Returns the value associated with the given key as an array or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as an array or nil if not present/convertible.
     */
    public subscript(key: JSONKey<[JSON]?>) -> [JSON]? {
        return self[key.type].jsonArray
    }
    
    /**
     Returns the value associated with the given key as an array or an empty array if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as an array or an empty array if not present/convertible.
     */
    public subscript(key: JSONKey<[JSON]>) -> [JSON] {
        return self[key.type].jsonArrayValue
    }
    
    /**
     Returns the value associated with the given key as a NSArray or nil if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSArray or nil if not present/convertible.
     */
    public subscript(key: JSONKey<NSArray?>) -> NSArray? {
        return self[key.type].nsArray
    }
    
    /**
     Returns the value associated with the given key as a NSArray or an empty NSArray if not present/convertible.
     
     - parameter key: The key.
     
     - returns: The value associated with the given key as a NSArray or an empty NSArray if not present/convertible.
     */
    public subscript(key: JSONKey<NSArray>) -> NSArray {
        return self[key.type].nsArrayValue
    }
}
