//
//  HelpCommand.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

final class HelpCommand: SubCommand {

    var parameters: [CommandParameterType] = []
    var name: String = "help"
    var argPrefix: String
    var optPrefix: String
    var subCommands: [SubCommand] = []
    
    private var commands: [Command]
    
    init(otherCommands: [Command]) {
        self.commands = otherCommands
        self.subCommands = otherCommands.map(_HelpWrapperCommand.init)
        
        // may be changed when printing, so store them during initialization
        self.argPrefix = Console.activeConfiguration.argumentPrefix
        self.optPrefix = Console.activeConfiguration.optionPrefix
    }
    
    func printHelp() {
        print(
            """
            Command:help
                Format: \n\t\t\(argPrefix)someArgument=value\n\t\t\(optPrefix)someOption[=optionalValue]

                For array values use following:\n\t\t\(argPrefix)someArgument=1,2,3,4

                Some of the arguments may have default values, but when used they must have some input.

                Options won't be used when not given in arguments,
                when used without optional value they will act as flags or be used with it's given default value.

                Use `help` subcommand with a given command to see it's help, e.g. `someCommand help`.
                Or it's name with the `help` command like `help otherCommand`. Note the latter will only work top level commands. 

            """
        )

        for cmd in commands {
            print("- \(cmd.name)")
            for h in cmd.help {
                print("\t\(h)")
            }
        }

        print()
    }

    func run(data: CommandData, with child: SubCommand?) throws {
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

    func shouldRun(subCommand: SubCommand) -> Bool {
        return false
    }
}

private final class _HelpWrapperCommand: SubCommand {

    let sourceCommand: Command
    var name: String {
        return sourceCommand.name
    }

    var subCommands: [SubCommand] = []
    var parameters: [CommandParameterType] {
        return []
    }

    init(wrapped: Command) {
        self.sourceCommand = wrapped
    }

    func printHelp() {
        sourceCommand.printHelp()
    }

    func run(data: CommandData, with child: SubCommand?) throws {
        throw CommandError.internalError // no subcommands supported
    }

    func run(data: CommandData, fromParent: Command) throws -> Bool {
        return true
    }
}
