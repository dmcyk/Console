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
    var subcommands: [Command] { get }
    var parameters: [CommandParameterType] { get }

    func run(data: CommandData, with child: Command?) throws
    func makeHelp() -> String
    func shouldRun(subcommand: Command) -> Bool
}

private let kHelpSubcommand = [_HelpSubcommand()]
extension Command {

    ///
    /// By default parameters that are defined as **instance properties**
    /// will be returned, through the Swift reflection APIs.
    ///
    /// - Important: In case of another way of defining parameters, one will have to provide
    /// manual list all of the parameters.
    public var parameters: [CommandParameterType] {
        return Mirror(reflecting: self)
            .children
            .compactMap {
                let raw = $0.value
                if let argument = raw as? ArgumentParameter {
                    return .argument(argument)
                } else if let option = raw as? OptionParameter {
                    return .option(option)
                }

                return nil
        }
    }

    public func shouldRun(subcommand: Command) -> Bool {
        return true
    }

    var console_subcommands: [Command] {
        return subcommands + kHelpSubcommand
    }
}

public protocol Subcommand: Command {

    /// true if parent should also run
    func run(data: CommandData, fromParent: Command) throws -> Bool
}

extension Subcommand {

    func run(data: CommandData, fromParent: Command) throws -> Bool {
        try self.run(data: data, with: nil)
        return false
    }
}

public enum CommandError: LocalizedError {

    case parameterNotAllowed(CommandParameter)
    case incorrectCommandName
    case unexpectedCommandParameter(String)
    case missingValueAfterEqualSign
    case missingOptionValue(CommandParameterType)
    case requstedFlagOnValueOption
    case internalError
    case missingCommand
    case commandNotFound(String)
    case nameCollision(String)
    case shortFormCollision(Character)
    case parameterNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .parameterNotAllowed(let param):
            return "Parameter not allowed \(param)"
        case .incorrectCommandName:
            return "Command not found, use `help`"
        case .missingValueAfterEqualSign:
            return "missingValueAfterEqualSign"
        case .requstedFlagOnValueOption:
            return "requstedFlagOnValueOption"
        case .internalError:
            return "implementation error"
        case .missingOptionValue(let parameter):
            return "Missing value for parameter: \(parameter.consoleName)"
        case .missingCommand:
            return "missingCommand, use 'help'"
        case .commandNotFound(let name):
            return "commandNotFound(\(name))"
        case .unexpectedCommandParameter(let str):
            return "unexpectedCommandParameter(\(str))"
        case .nameCollision(let name):
            return "nameCollision(\(name))"
        case .shortFormCollision(let ch):
            return "shortFormCollision(\(ch))"
        case .parameterNotFound(let str):
            return "parameter with name '\(str)' not found"
        }
    }

    public var recoverySuggestion: String? {
        return "Use `help` command"
    }
}

public extension Command {

    var subcommands: [Command] {
        return []
    }
    
    func makeHelp() -> String {
        var contents = "Command: \(name)" + .newline
        if !help.isEmpty {
            contents += "Help: "
                + help.joined(separator: .newline)
                + .newline
        }

        if !parameters.isEmpty {
            contents += "Parameters: " + .newline
        }

        contents += parameters.map { param -> String in
            var str = "\(String.indent)- "
            let description: [String]

            switch param {
            case .argument(let arg):
                let typeStr = arg.default.map {
                    "<\($0.description)>"
                } ?? "<\(arg.expected)>"
                str += "\(arg.name) Argument\(typeStr)"
                description = arg.description
            case .option(let opt):
                if opt is FlagOption {
                    str += "\(opt.name) Flag"
                } else {
                    let typeStr = opt.default.map {
                        "<\($0.description)>"
                    } ?? "<\(opt.expected)>"
                    str += "\(opt.name) Option\(typeStr)"
                }

                description = opt.description
            }

            if let first = description.first {
                str += " \(first)"

                str += description[1 ..< description.count].map {
                    "\(String.newline)\(String.indent(2))\($0)"
                }.joined()
            }

            return str
        }.joined(separator: .newline)

        contents += .newline
        let subcommandText: String = .withIndent {
            subcommands.map { "---" + .newline + $0.makeHelp() }
        }

        if !subcommandText.isEmpty {
            contents += .newline + "Subcommands: " + .newline + subcommandText
        }

        return contents
    }

    func printHelp() {
        print(makeHelp())
    }
    
}

extension Command {

    func prepareData(arguments: [String], parent: CommandData? = nil) throws -> CommandData {
        guard !arguments.isEmpty && arguments[0] == name else {
            throw CommandError.incorrectCommandName
        }
        
        return try CommandData(parameters, input: Array(arguments.suffix(from: 1)), subcommands: console_subcommands, parent: parent) // drop command name
    }
}
