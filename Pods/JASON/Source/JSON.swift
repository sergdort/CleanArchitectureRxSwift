//
// JSON.swift
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

// MARK: - Initializers

public struct JSON {
    /// The date formatter used for date conversions
    public static var dateFormatter = DateFormatter()
    
    /// The object on which any subsequent method operates
    public let object: AnyObject?

    /**
        Creates an instance of JSON from AnyObject.

        - parameter object: An instance of any class

        - returns: the created JSON
    */
    public init(_ object: Any?) {
        self.init(object: object)
    }

    /**
        Creates an instance of JSON from NSData.

        - parameter data: An instance of NSData

        - returns: the created JSON
    */
    public init(_ data: Data?) {
        self.init(object: JSON.objectWithData(data))
    }
    
    /**
        Creates an instance of JSON from a string.

        - parameter data: A string

        - returns: the created JSON
    */
    public init(_ string: String?) {
        self.init(string?.data(using: String.Encoding.utf8))
    }

    /**
        Creates an instance of JSON from AnyObject.
        Takes an explicit parameter name to prevent calls to init(_:) with NSData? when nil is passed.

        - parameter object: An instance of any class

        - returns: the created JSON
    */
    internal init(object: Any?) {
        self.object = object as AnyObject?
    }
}

// MARK: - Subscript

extension JSON {
    /**
        Creates a new instance of JSON.

        - parameter index: A string

        - returns: a new instance of JSON or itself if its object is nil.
    */
    public subscript(index: String) -> JSON {
        if object == nil { return self }

        if let nsDictionary = nsDictionary {
            return JSON(nsDictionary[index])
        }

        return JSON(object: nil)
    }

    /**
        Creates a new instance of JSON.

        - parameter index: A string

        - returns: a new instance of JSON or itself if its object is nil.
    */
    public subscript(index: Int) -> JSON {
        if object == nil { return self }

        if let nsArray = nsArray {
            return JSON(nsArray[safe: index])
        }

        return JSON(object: nil)
    }
    
    /**
        Creates a new instance of JSON.
        
        - parameter indexes: Any
        
        - returns: a new instance of JSON or itself if its object is nil
     */
    public subscript(path indexes: Any...) -> JSON {
        return self[indexes]
    }
    
    internal subscript(indexes: [Any]) -> JSON {
        if object == nil { return self }
        
        var json = self
        
        for index in indexes {
            if let string = index as? String, let object = json.nsDictionary?[string] {
                json = JSON(object)
                continue
            }
            
            if let int = index as? Int, let object = json.nsArray?[safe: int] {
                json = JSON(object)
                continue
            }
            
            else {
                json = JSON(object: nil)
                break
            }
        }
        
        return json
    }
}

// MARK: - Private extensions

private extension JSON {
    /**
        Converts an instance of NSData to AnyObject.

        - parameter data: An instance of NSData or nil

        - returns: An instance of AnyObject or nil
    */
    static func objectWithData(_ data: Data?) -> Any? {
        guard let data = data else { return nil }
        
        return try? JSONSerialization.jsonObject(with: data)
    }
}

