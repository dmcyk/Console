//
//  HelpCommand.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

private let kHelpCommandName = "help"

final class HelpCommand: Subcommand {

    let parameters: [CommandParameterType] = []
    let name: String = kHelpCommandName
    var argPrefix: String
    var optPrefix: String
    let subcommands: [Command]
    let help: [String] = []

    init(otherCommands: [Command]) {
        self.subcommands = otherCommands

        // may be changed when printing, so store them during initialization
        self.argPrefix = Console.activeConfiguration.argumentPrefix
        self.optPrefix = Console.activeConfiguration.optionPrefix
    }

    func makeHelp() -> String {
        var contents =
            """
            Command: \(name)
            Format: \(String.newline)\(String.indent)\(argPrefix)someArgument=value\(String.newline)\(String.indent)\(optPrefix)someOption[=optionalValue]

            For array values use following:\(String.newline)\(String.indent)\(argPrefix)someArgument=1,2,3,4

            Some of the arguments may have default values, but when used they must have some input.

            Options won't be used when not given in arguments,
            when used without optional value they will act as flags or be used with it's given default value.

            Use `\(name)` subcommand with a given command to see it's \(name), e.g. `someCommand \(name)`.
            Or it's name with the `\(name)` command like `\(name) otherCommand`. Note the latter will only work top level commands.

            """

        contents += subcommands.map { cmd -> String in
            .indent + "- `\(cmd.name)`:" + (cmd.help.first.map {
                " \($0)\(cmd.help.count > 1 ? "..." : "")"
            } ?? "")
        }.joined(separator: .newline)

        return contents + .newline
    }

    func run(data: CommandData, with child: Command?) throws {
        if let child = child {
            child.printHelp()
        } else {
            printHelp()
        }
    }

    func run(data: CommandData, fromParent: Command) throws -> Bool {
        fromParent.printHelp()
        return false
    }

    func shouldRun(subcommand: Subcommand) -> Bool {
        return false
    }
}

final class _HelpSubcommand: Subcommand {

    let name: String = kHelpCommandName
    let parameters: [CommandParameterType] = []
    let help: [String] = []

    func makeHelp() -> String {
        return ""
    }

    func run(data: CommandData, with child: Command?) throws {
        throw CommandError.internalError // no subcommands supported
    }

    func run(data: CommandData, fromParent: Command) throws -> Bool {
        fromParent.printHelp()
        return false
    }
}
