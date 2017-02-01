//
//  Option.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation


public struct Option {
    public enum Mode {
        case flag
        case value(expected: ValueType, `default`: Value?)
    }
    
    public enum Error: Swift.Error {
        case requestedValueInFlagMode, optionNotSet
    }
    
    public var name: String
    public var description: String? = nil
    var mode: Mode
    
    public init(_ name: String, description: String? = nil, mode: Mode) {
        self.name = name
        self.description = description
        self.mode = mode
    }
    
    public func flag(_ input: [String]) -> Bool {
        
        if case .flag = mode {
            for i in input {
                if i == consoleName {
                    return true
                }
            }
            return false
        }
        if let _val = try? value(input), let _ = _val {
            return true
        }
        return false
    }
    
    
    public func value(_ input: [String]) throws -> Value? {
        
        switch mode {
        case .flag:
            throw Error.requestedValueInFlagMode
        case .value(let expected, let def):
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
                    return def
                }
                
            }
            return nil
        }
        
    }
}

public extension Option {
    static func consolePrefix() -> String {
        return Console.activeConfiguration.optionPrefix
    }
    var consoleName: String {
        return Option.consolePrefix() + name
    }
}
