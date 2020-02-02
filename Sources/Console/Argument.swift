//
//  Argument.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.
//

import Foundation

public protocol ArgumentParameter: CommandParameter {

    var expected: ValueType { get }
    var `default`: Value? { get }

    func value(from argValue: String) throws -> Value?
}

public struct Argument<T: ParameterValue>: ArgumentParameter {

    public let name: String
    public let `default`: Value?
    public let description: [String]
    public let shortForm: Character?
    public let expected: ValueType

    public var parameterType: CommandParameterType {
        return .argument(self)
    }
    
    public init(_ name: String, description: [String] = [], `default`: T? = nil, shortForm: Character? = nil) {
        self.name = name
        self.description = description
        self.expected = T.valueType
        self.default = `default`?.asValue
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

    func value(usedByUser: Bool, fromArgValue: String?) throws -> Value? {
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
