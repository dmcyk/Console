//
//  Value.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.
//

import Foundation

public enum ValueError: LocalizedError {

    case noValue(ValueType, Value), compundIsNotTopLevelType

    public var errorDescription: String? {
        switch self {
        case .noValue(let expected, let got):
            return "noValue: expected - \(expected), got - \(got)"
        case .compundIsNotTopLevelType:
            return "compundIsNotTopLevelType"
        }
    }
}

public enum Value: CustomStringConvertible {

    case int(Int)
    case double(Double)
    case string(String)
    /// Homogeneous array value type
    case array([Value], ValueType)
    case bool(Bool)
    
    public func intValue() throws -> Int {
        if case .int(let value) = self {
            return value
        }
        throw ValueError.noValue(.int, self)
    }
    
    public func doubleValue() throws -> Double {
        if case .double(let value) = self {
            return value
        }
        throw ValueError.noValue(.double, self)
    }
    
    public func arrayValue() throws -> [Value] {
        if case .array(let value, _) = self {
            return value
        }
        throw ValueError.noValue(.compound, self)
    }
    
    public func stringValue() throws -> String {
        if case .string(let val) = self {
            return val
        }
        throw ValueError.noValue(.string, self)
    }
    
    public func boolValue() throws -> Bool {
        if case .bool(let val) = self {
            return val
        }
        throw ValueError.noValue(.bool, self)
    }
    
    public var description: String {
        switch self {
        case .int(let val):
            return "Int(\(val))"
        case .double(let val):
            return "Double(\(val))"
        case .string(let val):
            return "String(\(val))"
        case .array(let val, let type):
            return "Array<\(type.description)>(\(val.map { $0.string }.joined(separator: ",")))"
        case .bool(let val):
            return "Bool(\(val))"
        }
    }
    
    public var string: String {
        switch self {
        case .int(let val):
            return "\(val)"
        case .double(let val):
            return "\(val)"
        case .string(let val):
            return val
        case .bool(let val):
            return val ? "true" : "false"
        case .array(let val, _):
            return "(" + val.map( { $0.string }).joined(separator: ",") + ")"
        }
    }

    public var double: Double? {
        switch self {
        case .int(let val):
            return Double(val)
        case .double(let val):
            return val
        case .string(let val):
            return Double(val)
        case .array(let value, _):
            if let first = value.first, value.count == 1 {
                return first.double
            }
            return nil
        case .bool(let val):
            return val ? 1 : 0
        }
    }

    public var integer: Int? {
        switch self {
        case .int(let val):
            return val
        case .double(let val):
            return Int(val)
        case .string(let val):
            return Int(val)
        case .array(let value, _):
            if let first = value.first, value.count == 1 {
                return first.integer
            }
            return nil
        case .bool(let val):
            return val ? 1 : 0
        }
    }

    public var boolean: Bool? {
        switch self {
        case .int(let val):
            return val != 0
        case .double(let val):
            return val != 0
        case .string(let val):
            if let int = integer {
                return int != 0
            } else if let double = double {
                return double != 0
            } else {
                let lowercased = val.lowercased()

                if lowercased == "true" {
                    return true
                } else if lowercased == "false" {
                    return false
                }

                return nil
            }
        case .bool(let val):
            return val
        case .array(let values, _):
            if let first = values.first, values.count == 1 {
                return first.boolean
            }

            return nil
        }
    }
    
    public var type: ValueType {
        switch self {
        case .int:
            return .int
        case .double:
            return .double
        case .string:
            return .string
        case .array(_, let type):
            return .array(type)
        case .bool:
            return .bool
        }
    }
}

public extension Value {

    /// Parse dynamic set of values into the `Value` type
    ///
    /// - Parameter values: if `empty` the returned `Value` will be of type `array` with `compund` ValueType
    /// - Returns: `Value` with case `array`
    static func dynamicArray(from values: [Value]) -> Value {
        guard let firstType = values.first?.type else {
            // empty array, fallback to `compund`
            return .array([], .compound)
        }

        for value in values[1 ..< values.count] {
            if value.type != firstType {
                return Value.array(values, .compound)
            }
        }

        return .array(values, firstType)
    }
}
