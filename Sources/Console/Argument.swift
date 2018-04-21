//
//  Argument.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public protocol ArgumentParameter: CommandParameter {

    var expected: ValueType { get }
    var `default`: Value? { get }

    func value(from argValue: String) throws -> Value?
}

public struct Argument: ArgumentParameter {

    public var expected: ValueType
    public var name: String
    public var `default`: Value?
    public var description: [String]
    public var shortForm: Character? = nil 

    
    public init(_ name: String, expected: ValueType, description: [String] = [], `default`: Value? = nil, shortForm: Character? = nil) {
        self.name = name
        self.description = description
        self.expected = expected
        self.default = `default`
        self.shortForm = shortForm
    }

    public func value(from argValue: String) throws -> Value? {
        return try CommandParameterType.extractValue(expected: expected, strValue: argValue)
    }
}

public extension ArgumentParameter {

    static func consolePrefix() -> String {
        return Console.activeConfiguration.argumentPrefix
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
            return try self.value(from: val)
        } else {
            throw ArgumentError.argumentWithoutValueFound(name) // arguments must have value if given
        }
    }
}
