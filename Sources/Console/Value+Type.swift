//
//  Value+Type.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

///
///
/// - int: integer
/// - double: double
/// - string: string
/// - array: typed array
/// - bool: boolean
/// - compound: mixed array 
public indirect enum ValueType: CustomStringConvertible {
    case int, double, string, array(ValueType), bool, compound
    
    public var description: String {
        switch self {
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .string:
            return "String"
        case .array(let type):
            return "Array<\(type.description)>"
        case .bool:
            return "Bool"
        case .compound:
            return "Compound"
        }
    }
}

extension ValueType: Equatable {
    
    public static func ==(lhs: ValueType, rhs: ValueType) -> Bool {
        switch (lhs, rhs) {
        case (.int, .int),
             (.double, .double),
             (.string, .string),
             (.compound, .compound),
             (.bool, .bool):
            return true
        case (.array(let _lhs),.array(let _rhs)):
            return _lhs == _rhs
        default:
            return false
        }
    }
}
