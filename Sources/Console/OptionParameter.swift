//
//  Option.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public protocol OptionParameter: CommandParameter {

    var expected: ValueType { get }
    var `default`: Value? { get }
}

public struct Option<T: ParameterValue>: OptionParameter {
    
    public let name: String
    public let description: [String]
    public let shortForm: Character?
    public let expected: ValueType
    public let `default`: Value?

    public var parameterType: CommandParameterType {
        return .option(self)
    }
    
    public init(_ name: String, description: [String] = [], `default`: T? = nil, shortForm: Character? = nil) {
        self.name = name
        self.description = description
        self.expected = T.valueType
        self.shortForm = shortForm
        self.`default` = `default`?.asValue
    }
    
    public func value(usedByUser: Bool, fromArgValue arg: String?) throws -> Value? {
        if let arg = arg {
            return try CommandParameterType.extractValue(expected: expected, strValue: arg)
        } else {
            if usedByUser && `default` == nil {
                throw CommandError.requstedFlagOnValueOption
            }

            return `default`
        }
    }
}

public struct FlagOption: OptionParameter {

    public let name: String
    public let description: [String]
    public let shortForm: Character?
    /// Flags do not have default
    public let _default: Bool = false

    public var expected: ValueType { return .bool }
    public var `default`: Value? { return .bool(_default) }

    public var parameterType: CommandParameterType {
        return .option(self)
    }

    public init(_ name: String, description: [String] = [], shortForm: Character? = nil) {
        self.name = name
        self.description = description
        self.shortForm = shortForm
    }

    public func value(usedByUser: Bool, fromArgValue arg: String?) throws -> Value? {
        guard usedByUser else {
            return .bool(_default)
        }

        return .bool(arg == nil) // no value allowed for flag params
    }
}

public extension OptionParameter {

    static func consolePrefix() -> String {
        return Console.activeConfiguration.optionPrefix
    }
}
