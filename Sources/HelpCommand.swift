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
        
        // may be changed when printing, so store them during initialization
        self.argPrefix = Console.activeConfiguration.argumentPrefix
        self.optPrefix = Console.activeConfiguration.optionPrefix
    }
    
    func printHelp() {
        print("Command: help")
        print("\tFormat: \n\t\t\(argPrefix)someArgument=value\n\t\t\(optPrefix)someOption[=optionalValue]")
        print("\tFor array values use following:\n\t\t\(argPrefix)someArgument=1,2,3,4\n")
        print("\tSome arguments may have default values, but when used they are required to have some value.\n")
        print("\tOptions won't be used when not given in arguments,\n\twhen used without optional value they will act as flags or be used with given default value")
        print("\n\tUse help subcommand with a given command to see it's help\n\tOr it's name with the `help` command, i.e., `help otherCommand`\n\n")
        
        for cmd in commands {
            print("- \(cmd.name)")
            for h in cmd.help {
                print("\t\(h)")
            }
            print("\n")
        }
    }
    
    func run(data: CommandData) throws {
        printHelp()
    }
    
    func run(data: CommandData, fromParent: Command) throws -> Bool {
        fromParent.printHelp()
        return false;
    }
    
}
