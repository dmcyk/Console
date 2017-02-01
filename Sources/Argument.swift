//
//  Argument.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation


public struct Argument: CommandParameter {
    public var expected: ValueType
    public var name: String
    public var `default`: Value?
    public var description: String? = nil
    public var shortForm: Character? = nil 

    
    public init(_ name: String, expectedValue: ValueType, description: String? = nil, `default`: Value? = nil ) {
        self.name = name
        self.description = description
        self.expected = expectedValue
        self.default = `default`
    }
    
    public func value(usedByUser: Bool, fromArgValue: String?) throws -> Value? {
        guard usedByUser else {
            if let def = `default` {
                return def
            } else {
                throw ArgumentError.noValue(name)
            }
        }
        
        if let val = fromArgValue {
            return try CommandParameterType.extractValue(expected: expected, strValue: val)
        } else {
            throw ArgumentError.argumentWithoutValueFound(name) // arguments must have value if given
        }
    }
    
}

public extension Argument {
    static func consolePrefix() -> String {
        return Console.activeConfiguration.argumentPrefix
    }
}
