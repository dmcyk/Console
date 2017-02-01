//
//  Argument.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation


public struct Argument {
    public var expected: ValueType
    public var name: String
    public var `default`: Value?
    public var description: String? = nil
    
    public init(_ name: String, expectedValue: ValueType, description: String? = nil, `default`: Value? = nil ) {
        self.name = name
        self.description = description
        self.expected = expectedValue
        self.default = `default`
    }
    
    public func value(_ input: [String]) throws -> Value {
        let nameFormat = consoleName
        for src in input {
            
            if let equal = src.characters.index(of: "=") {
                guard nameFormat == src.substring(to: equal) else {
                    continue
                }
                let afterEqual = src.characters.index(after: equal)
                let value = src.substring(from: afterEqual)
                
                return try CommandParameter.extractValue(expected: expected, strValue: value)
                
            } else if nameFormat == src {
                throw ArgumentError.argumentWithoutValueFound(name)
            }
            
        }
        if let def = `default` {
            return def
        } else {
            throw ArgumentError.noValue(name)
        }
    }
    
}

public extension Argument {
    static func consolePrefix() -> String {
        return Console.activeConfiguration.argumentPrefix
    }
    
    var consoleName: String {
        return Argument.consolePrefix() + name
    }
}
