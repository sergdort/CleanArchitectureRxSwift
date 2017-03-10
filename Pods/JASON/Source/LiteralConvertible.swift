//
// LiteralConvertible.swift
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

// MARK: - StringLiteralConvertible

/// Conforming types can be initialized with arbitrary string literals.
extension JSON: ExpressibleByStringLiteral {
    /**
        Creates an instance of JSON from a string literal

        - parameter stringLiteral: A string literal

        - returns: An instance of JSON
    */
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    /**
        Creates an instance of JSON from a string literal

        - parameter extendedGraphemeClusterLiteral: A string literal

        - returns: An instance of JSON
    */
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }

    /**
        Creates an instance of JSON from a string literal

        - parameter unicodeScalarLiteral: A string literal

        - returns: An instance of JSON
    */
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
}

// MARK: - IntegerLiteralConvertible

/// Conforming types can be initialized with integer literals.
extension JSON: ExpressibleByIntegerLiteral {
    /**
        Creates an instance of JSON from an integer literal.

        - parameter integerLiteral: An integer literal

        - returns: An instance of JSON
    */
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

// MARK: - FloatLiteralConvertible

/// Conforming types can be initialized with float literals.
extension JSON: ExpressibleByFloatLiteral {
    /**
        Creates an instance of JSON from a float literal.

        - parameter floatLiteral: A float literal

        - returns: An instance of JSON
    */
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

// MARK: - BooleanLiteralConvertible

/// Conforming types can be initialized with the Boolean literals true and false.
extension JSON: ExpressibleByBooleanLiteral {
    /**
        Creates an instance of JSON from a boolean literal.

        - parameter booleanLiteral: A boolean literal

        - returns: An instance of JSON
    */
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

// MARK: - DictionaryLiteralConvertible

/// Conforming types can be initialized with dictionary literals.
extension JSON: ExpressibleByDictionaryLiteral {
    /**
        Creates an instance of JSON from a dictionary literal.

        - parameter dictionaryLiteral: A dictionary literal

        - returns: An instance of JSON
    */
    public init(dictionaryLiteral elements: (String, Any)...) {
        var dictionary = [String: Any]()

        for (key, value) in elements {
            dictionary[key] = value
        }

        self.init(dictionary)
    }
}

// MARK: - ArrayLiteralConvertible

/// Conforming types can be initialized with array literals.
extension JSON: ExpressibleByArrayLiteral {
    /**
        Creates an instance of JSON from an array literal.

        - parameter arrayLiteral: An array literal

        - returns: An instance of JSON
    */
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

// MARK: - NilLiteralConvertible

/// Conforming types can be initialized with nil.
extension JSON: ExpressibleByNilLiteral {
    /**
        Creates an instance of JSON from a nil literal.

        - parameter nilLiteral: A nil literal

        - returns: An instance of JSON
    */
    public init(nilLiteral: ()) {
        self.init(object: nil)
    }
}
