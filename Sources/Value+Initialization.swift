//
//  Value+Initialization.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

extension Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension Value: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public typealias UnicodeScalarLiteralType = String
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .string(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .string(value)
    }
}

extension Value: Equatable {
    
    public static func ==(lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.int(let lval), .int(let rval)):
            return lval == rval
        case (.double(let lval), .double(let rval)):
            return lval == rval
        case (.string(let lval), .string(let rval)):
            return lval == rval
        case (.bool(let lval), .bool(let rval)):
            return lval == rval
        case (.array(let lval), .array(let rval)):
            return lval.0 == rval.0
        default:
            return false
        }
    }
}

extension Value: Comparable {
    public static func <(lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.int(let lval), .int(let rval)):
            return lval < rval
        case (.double(let lval), .double(let rval)):
            return lval < rval
        case (.string(let lval), .string(let rval)):
            return lval < rval
        default:
            return false
        }
    }
    
}

extension Value: ExpressibleByArrayLiteral {
    public typealias Element = Value
    
    public init(arrayLiteral elements: Element...) {
        var type: ValueType = .compound
        if !elements.isEmpty {
            type = elements[0].type
            for e in elements.suffix(from: 1) {
                
                if e.type != type {
                    type = .compound
                    break
                }
            }
        }
        self = .array(elements, type)
    }
}
