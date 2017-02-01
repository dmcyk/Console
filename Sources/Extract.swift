//
//  Utils.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

extension CommandParameterType {
    static func extractInt(_ src: String) throws -> Int {
        
        guard let number = Int(src) else {
            throw ArgumentError.incorrectValue
        }
        return number
    }
    
    static func extractDouble(_ src: String) throws -> Double {
        
        guard let number = Double(src) else {
            throw ArgumentError.incorrectValue
        }
        return number
    }
    
    static func extractBool(_ src: String) throws -> Value {
        let lower = src.lowercased()
        if lower == "false" || lower == "0" {
            return false
        } else if lower == "true" || lower == "1" {
            return true
        } else {
            throw ArgumentError.incorrectValue
        }
    }
    
    static func extractValue(expected: ValueType, strValue value: String) throws -> Value {
        switch expected {
        case .int:
            let number = try extractInt(value)
            return .int(number)
        case .double:
            let number = try extractDouble(value)
            return .double(number)
        case .string:
            return .string(value)
        case .bool:
            return try extractBool(value)
        case .array(let inner):
            let values = value.components(separatedBy: ",")
            switch inner {
            case .double:
                return try .array(values.map {
                    try .double(extractDouble($0))
                }, .double)
            case .int:
                return try .array(values.map {
                    try .int(extractInt($0))
                }, .int)
            case .string:
                return .array(values.map {
                    .string($0)
                }, .string)
            case .bool:
                return try .array(values.map {
                    try extractBool($0)
                }, .bool)
            case .compound:
                let valuesMapped: [Value] = values.map {
                    
                    if let i: Value = try? .int(extractInt($0)) {
                        return i
                    } else if let d: Value = try? .double(extractDouble($0)) {
                        return d
                    } else if let i: Value = try? extractBool($0) {
                        return i
                    } else {
                        return .string($0)
                    }
                }
                return .array(valuesMapped, .compound)
            case .array(_):
                throw ArgumentError.indirectValue
                
            }
        case .compound:
            throw ValueError.compundIsNotTopLevelType
        }
    }
}
