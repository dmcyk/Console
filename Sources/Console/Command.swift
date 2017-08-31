//
//  Command.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation


public protocol Command: class {
    var help: [String] { get }
    var name: String { get }
    var subCommands: [SubCommand] { get set }
    var parameters: [CommandParameterType] { get }
    
    func run(data: CommandData) throws
    func printHelp()
}

public protocol SubCommand: Command {
    
    func run(data: CommandData, fromParent: Command) throws -> Bool // true if main command should run as well
}

extension Command {
    public func willRunSubcommand(cmd: Command) {
        
    }
}

public enum CommandError: Error {
    case parameterNotAllowed(CommandParameter)
    case notEnoughArguments
    case incorrectCommandName
    case unexpectedCommandParameter(String)
    case missingValueAfterEqualSign
    case missingOptionValue
    case requstedFlagOnValueOption
    case internalError
    case missingCommand
    case commandNotFound(String)
    case nameCollision(String)
    case shortFormCollision(Character)
    case parameterNotFound(String)
    
    public var localizedDescription: String {
        switch self {
        case .parameterNotAllowed(let param):
            return "Parameter not allowed \(param)"
        case .notEnoughArguments:
            return "Not enough arguments, use `command -help` or `help`"
        case .incorrectCommandName:
            return "Command not found, use `help`"
        case .missingValueAfterEqualSign:
            return "missingValueAfterEqualSign"
        case .requstedFlagOnValueOption:
            return "requstedFlagOnValueOption"
        case .internalError:
            return "implementation error"
        case .missingOptionValue:
            return "missingOptionValue"
        case .missingCommand:
            return "missingCommand, use 'help'"
        case .commandNotFound(let name):
            return "commandNotFound(\(name))"
        case .unexpectedCommandParameter(let str):
            return "unexpectedCommandParameter\(str)"
        case .nameCollision(let name):
            return "name collision: \(name)"
        case .shortFormCollision(let ch):
            return "short form collision \(ch)"
        case .parameterNotFound(let str):
            return "parameter with name '\(str)' not found"
        }
    }
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
            let description: [String]
            
            switch param {
            case .argument(let arg):
                let typeStr = arg.default != nil ? "<\(arg.default!.description)>" : "<\(arg.expected)>"
                print("\t- \(arg.name) Argument\(typeStr)", terminator: "")
                description = arg.description
            case .option(let opt):
                switch opt.mode {
                case .flag:
                    print("\t- \(opt.name) Flag", terminator: "")
                case .value(let expected, let def):
                    let typeStr = def != nil ? "<\(def!.description)>" : "<\(expected)>"
                    print("\t- \(opt.name) Option\(typeStr)", terminator: "")
                    
                }
                description = opt.description
            }
            if let first = description.first {
                print(" \(first)", terminator: "")
                
                var i = 1
                
                while ( i < description.count) {
                    print("\n\t\t\(description[i])", terminator: "")
                    i += 1
                }
            }
            print()
        }
        print()
    }
    
}


extension Command {
    
    func prepareData(arguments: [String]) throws -> CommandData {
        guard !arguments.isEmpty && arguments[0] == name else {
            throw CommandError.incorrectCommandName
        }
        
        return try CommandData(parameters, input: Array(arguments.suffix(from: 1)), subcommands: subCommands) // drop command name
    }

    
}