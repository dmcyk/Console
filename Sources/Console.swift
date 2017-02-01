//
//  Console.swift
//  Task1
//
//  Created by Damian Malarczyk on 14.10.2016.
//  Copyright © 2016 Damian Malarczyk. All rights reserved.
//

import Foundation

public class HelpCommand: Command {
    private var commands: [Command]
    
    init(otherCommands: [Command]) {
        self.commands = otherCommands
    }
    
    public func printHelp() {
        print("Command: help")
        print("\tFormat: \n\t\t-someArgument=value\n\t\t--someOption[=optionalValue]")
        print("\tFor array values use following:\n\t\t-someArgument=1,2,3,4\n")
        print("\tSome arguments may have default values, but when used they are required to have some value")
        print("\tOptions won't be used when not given in arguments, when used without optional value they will act as flags or be used with given default value")
        print("\n\tUse --help flag with a given command to see it's help\n\tOr it's name with the `help` command, i.e., `help otherCommand`\n\n")
        print("\tprinting help for all commands...\n")
        for cmd in commands {
            cmd.printHelp()
        }
    }
    public func run(data: CommandData) throws {
        if data.input.isEmpty {
            printHelp()
            return
        }
        let specificCommand = data.input[0]
        for c in commands {
            if c.name == specificCommand {
                c.printHelp()
                break
            }
        }
    }
    
    public var parameters: [CommandParameter] = []
    
    public var name: String = "help"
    
}

public class Console {
    public var arguments: [String]
    private var commands: [Command]
    
    public init(arguments: [String], commands _commands: [Command], trimFirst: Bool = true) throws {
        var commands = _commands
        commands.append(HelpCommand(otherCommands: _commands))
        self.commands = commands
        
        if trimFirst {
            self.arguments = Array(arguments.suffix(from: 1))
        } else {
            self.arguments = arguments
        }
        
    }
    
    public func run() throws {
        guard !arguments.isEmpty else {
            commands.last!.printHelp() // last is always help
            return
        }
        for cmd in commands {
            do {
                try cmd.parse(arguments: arguments)
                return
            } catch CommandError.incorrectCommandName {
            }
            
        }
        print("\(arguments[0]) is an incorrect command")
    }
}

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
        case (.int, .int):
            return true
        case (.double, .double):
            return true
        case (.string, .string):
            return true
        case (.compound, .compound):
            return true
        case (.array(let _lhs),.array(let _rhs)):
            return _lhs == _rhs
        default:
            return false
        }
    }
}

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

extension Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension Value: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public typealias UnicodeScalarLiteralType = String
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .string(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .string(value)
    }
}

extension Value: Equatable {
    
    public static func ==(lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.int(let lval), .int(let rval)):
            return lval == rval
        case (.double(let lval), .double(let rval)):
            return lval == rval
        case (.string(let lval), .string(let rval)):
            return lval == rval
        case (.bool(let lval), .bool(let rval)):
            return lval == rval
        case (.array(let lval), .array(let rval)):
            return lval.0 == rval.0
        default:
            return false
        }
    }
}

extension Value: Comparable {
    public static func <(lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.int(let lval), .int(let rval)):
            return lval < rval
        case (.double(let lval), .double(let rval)):
            return lval < rval
        case (.string(let lval), .string(let rval)):
            return lval < rval
        default:
            return false
        }
    }
    
}

extension Value: ExpressibleByArrayLiteral {
    public typealias Element = Value
    
    public init(arrayLiteral elements: Element...) {
        var type: ValueType = .compound
        if !elements.isEmpty {
            type = elements[0].type
            for e in elements.suffix(from: 1) {
                
                if e.type != type {
                    type = .compound
                    break
                }
            }
        }
        self = .array(elements, type)
    }
}

public enum ArgumentError: Error {
    case incorrectValue, indirectValue, noValue(String), argumentWithoutValueFound(String) //no equal sign
    
    public var localizedDescription: String {
        switch self {
        case .indirectValue:
            return "nestedTypesNotSupported"
        case .incorrectValue:
            return "Couldn't parse value"
        case .noValue(let name):
            return "Argument `\(name)` is missing value"
        case .argumentWithoutValueFound(let name):
            return "Argument `\(name)` used but no value was given"
        }
    }
}

public struct ContainedArgumentError: Error {
    public let error: ArgumentError
    public let argument: Argument
    
    public init(error: ArgumentError, argument: Argument) {
        self.error = error
        self.argument = argument
    }
}

public protocol Command {
    var help: [String] { get }
    var name: String { get }
    var parameters: [CommandParameter] { get }
    
    func run(data: CommandData) throws
    func printHelp()
    
}

public extension Command {
    var help: [String] {
        return []
    }
    
    func printHelp() {
        print("Command: \(name)")
        for line in help {
            print(line)
        }
        print()
        for param in parameters {
            switch param {
            case .argument(let arg):
                print("\t- \(arg.name) Argument(\(arg.expected)) \(arg.description ?? "")")
            case .option(let opt):
                switch opt.mode {
                case .flag:
                    print("\t- \(opt.name) Flag \(opt.description ?? "")")
                case .value(_, let def):
                    print("\t- \(opt.name) Option(\(def ?? "")) \(opt.description ?? "")")
                    
                }
            }
        }
        print()
    }
    
    func parse(arguments: [String]) throws {
        guard !arguments.isEmpty && arguments[0] == name else {
            throw CommandError.incorrectCommandName
        }
        
        if Option("help", mode: .flag).flag(arguments) {
            printHelp()
            return
        }
        
        let data = try CommandData(parameters, input: Array(arguments.suffix(from: 1)))
        
        
        try run(data: data)
        
    }
}

public enum CommandError: Error {
    case parameterNameNotAllowed
    case notEnoughArguments
    case incorrectCommandName
    
    public var localizedDescription: String {
        switch self {
        case .parameterNameNotAllowed:
            return "Parameter name not allowed"
        case .notEnoughArguments:
            return "Not enough arguments, use `command -help` or `help`"
        case .incorrectCommandName:
            return "Command not found, use `help`"
        }
    }
}

public struct CommandData {
    private var arguments: [String: Argument]
    private var options: [String: Option]
    fileprivate var input: [String]
    
    public init(_ parameters: [CommandParameter], input: [String]) throws {
        arguments = [:]
        options = [:]
        self.input = input
        
        for param in parameters {
            switch param {
            case .argument(let arg):
                _ = try arg.value(input)
                arguments[arg.name] = arg
                
            case .option(let opt):
                options[opt.name] = opt
            }
        }
    }
    
    
    
    
    public func argumentValue(_ argName: String) throws -> Value {
        
        guard let argument = arguments[argName] else {
            throw CommandError.parameterNameNotAllowed
        }
        return try argument.value(input)
        
    }
    
    public func flag(_ name: String) throws -> Bool {
        guard let option = options[name] else {
            throw CommandError.parameterNameNotAllowed
        }
        return option.flag(input)
    }
    
    public func optionValue(_ name: String) throws -> Value? {
        guard let option = options[name] else {
            throw CommandError.parameterNameNotAllowed
        }
        return try option.value(input)
    }
}

public enum CommandParameter {
    case option(Option)
    case argument(Argument)
    
}

public struct Option {
    public enum Mode {
        case flag
        case value(expected: ValueType, `default`: Value?)
    }
    
    public enum Error: Swift.Error {
        case requestedValueInFlagMode, optionNotSet
    }
    
    public var name: String
    fileprivate var mode: Mode
    public var description: String? = nil
    
    
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
                    
                    return try extractValue(expected: expected, strValue: value)
                    
                } else if nameFormat == src {
                    return def
                }
                
            }
            return nil
        }
        
    }
}

public extension Option {
    var consoleName: String {
        return "--\(name)"
    }
}

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
        let nameFormat = "-\(name)"
        for src in input {
            
            if let equal = src.characters.index(of: "=") {
                guard nameFormat == src.substring(to: equal) else {
                    continue
                }
                let afterEqual = src.characters.index(after: equal)
                let value = src.substring(from: afterEqual)
                
                return try extractValue(expected: expected, strValue: value)
                
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
    var consoleName: String {
        return "-\(name)"
    }
}

fileprivate func extractInt(_ src: String) throws -> Int {
    
    guard let number = Int(src) else {
        throw ArgumentError.incorrectValue
    }
    return number
}

fileprivate func extractDouble(_ src: String) throws -> Double {
    
    guard let number = Double(src) else {
        throw ArgumentError.incorrectValue
    }
    return number
}

fileprivate func extractBool(_ src: String) throws -> Value {
    let lower = src.lowercased()
    if lower == "false" || lower == "0" {
        return .bool(false)
    } else if lower == "true" || lower == "1" {
        return .bool(true)
    } else {
        throw ArgumentError.incorrectValue
    }
}

fileprivate func extractValue(expected: ValueType, strValue value: String) throws -> Value {
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
            let values: [Value] = values.flatMap {
                if let d: Value = try? .double(extractDouble($0)) {
                    return d
                } else if let i: Value = try? .int(extractInt($0)) {
                    return i
                } else {
                    return .string($0)
                }
            }
            return .array(values, .compound)
        case .array(_):
            throw ArgumentError.indirectValue
            
        }
    case .compound:
        throw ValueError.compundIsNotTopLevelType
    }
}



