//
//  Command.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public protocol Command {
    var help: [String] { get }
    var name: String { get }
    var subCommands: [Command] { get }
    var parameters: [CommandParameterType] { get }
    
    func run(data: CommandData) throws
    func printHelp()
    
    func willRunSubcommand(cmd: Command)
}

extension Command {
    public func willRunSubcommand(cmd: Command) {
        
    }
}

public enum CommandError: Error {
    case parameterNotAllowed(CommandParameter)
    case notEnoughArguments
    case incorrectCommandName
    case incorrectCommandOption(String)
    case missingValueAfterEqualSign
    case missingOptionValue
    case requstedFlagOnValueOption
    case internalError
    case missingCommand
    case commandNotFound(String)
    case nameCollision(String)
    case shortFormCollision(Character)
    
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
            return "missingCommand"
        case .commandNotFound(let name):
            return "commandNotFound(\(name))"
        case .incorrectCommandOption(let str):
            return "incorrectCommandOption\(str)"
        case .nameCollision(let name):
            return "name collision: \(name)"
        case .shortFormCollision(let ch):
            return "short form collision \(ch)"
        }
    }
}

public extension Command {
    var help: [String] {
        return []
    }
    
    var subCommands: [Command] {
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
    
}


extension Command {
    
    func prepareData(arguments: [String]) throws -> CommandData {
        guard !arguments.isEmpty && arguments[0] == name else {
            throw CommandError.incorrectCommandName
        }
        
        return try CommandData(parameters, input: Array(arguments.suffix(from: 1)), subcommands: subCommands) // drop command name
    }

    
}
