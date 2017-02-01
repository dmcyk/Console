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
    
}

public enum CommandError: Error {
    case parameterNotAllowed(CommandParameter)
    case notEnoughArguments
    case unregonizedInput(String)
    case incorrectCommandName
    case missingValueAfterEqualSign
    case requstedFlagOnValueOption
    case internalError
    
    public var localizedDescription: String {
        switch self {
        case .parameterNotAllowed(let param):
            return "Parameter not allowed \(param)"
        case .notEnoughArguments:
            return "Not enough arguments, use `command -help` or `help`"
        case .incorrectCommandName:
            return "Command not found, use `help`"
        case .unregonizedInput(let str):
            return "Unregonized: \(str)"
        case .missingValueAfterEqualSign:
            return "missingValueAfterEqualSign"
        case .requstedFlagOnValueOption:
            return "requstedFlagOnValueOption"
        case .internalError:
            return "implementation error" 
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
    
    func parse(arguments: [String]) throws {
        guard !arguments.isEmpty && arguments[0] == name else {
            throw CommandError.incorrectCommandName
        }
        
        let data = try CommandData(parameters, input: Array(arguments.suffix(from: 1)), subcommands: subCommands) // drop command name
        
        try run(data: data)
        
    }
}
