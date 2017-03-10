//
// Utilities.swift
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

internal extension NSArray {
    /**
        Returns the element at the given index or nil if the index is out of bounds.

        - parameter index: An integer

        - returns: The element at the given index or nil
    */
    @nonobjc subscript(safe index: Int) -> Any? {
        guard index >= 0 && index < count else { return nil }

        return self[index]
    }
}

internal extension Dictionary {
    func reduceValues <T: Any>(_ transform: (Value) -> T) -> [Key: T] {
        return reduce([Key: T]()) { (dictionary, kv) in
            var dictionary = dictionary
            dictionary[kv.0] = transform(kv.1)
            return dictionary
        }
    }
}
