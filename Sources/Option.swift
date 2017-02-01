//
//  Option.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation


public struct Option: CommandParameter {
    public enum Mode {
        case flag
        case value(expected: ValueType, `default`: Value?)
    }
    
    public enum Error: Swift.Error {
        case requestedValueInFlagMode, optionNotSet
    }
    
    public var name: String
    public var description: String? = nil
    public var shortForm: Character? = nil
    var mode: Mode
    
    public init(_ name: String, description: String? = nil, mode: Mode) {
        self.name = name
        self.description = description
        self.mode = mode
    }
    
    public func value(usedByUser: Bool, fromArgValue arg: String?) throws -> Value? {
        switch mode {
        case .flag:
            guard usedByUser else {
                return false 
            }
            return .bool(arg == nil) // no value allowed for flag params
        case .value(let expected, let def):
            if let arg = arg {
                return try CommandParameterType.extractValue(expected: expected, strValue: arg)
            } else {
                return def
            }
        }
    }
}

public extension Option {
    static func consolePrefix() -> String {
        return Console.activeConfiguration.optionPrefix
    }
    
}
