//
//  Value.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public enum ValueError: Error {

    case noValue, compundIsNotTopLevelType
}

public enum Value: CustomStringConvertible {

    case int(Int)
    case double(Double)
    case string(String)
    case array([Value], ValueType)
    case bool(Bool)
    
    public func intValue() throws -> Int {
        if case .int(let value) = self {
            return value
        }
        throw ValueError.noValue
    }
    
    public func doubleValue() throws -> Double {
        if case .double(let value) = self {
            return value
        }
        throw ValueError.noValue
    }
    
    public func arrayValue() throws -> [Value] {
        if case .array(let value, _) = self {
            return value
        }
        throw ValueError.noValue
    }
    
    public func stringValue() throws -> String {
        if case .string(let val) = self {
            return val
        }
        throw ValueError.noValue
    }
    
    public func boolValue() throws -> Bool {
        if case .bool(let val) = self {
            return val
        }
        throw ValueError.noValue
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
            return "Array<\(type.description)>(\(val.map { $0.description }.joined(separator: ",")))"
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
            return val.map( { $0.string }).joined(separator: ",")
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
