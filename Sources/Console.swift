//
//  Console.swift
//  Task1
//
//  Created by Damian Malarczyk on 14.10.2016.
//  Copyright © 2016 Damian Malarczyk. All rights reserved.
//

import Foundation

public class Console {
    static var activeConfiguration: Configuration = Console.defaultConfiguration()
    public var commands: [Command]
    private var configuration: Configuration
    
    public init(commands _commands: [Command], configuration rawConf: Console.Configuration? = nil) {
        var commands = _commands
        
        let currentlyActive = Console.activeConfiguration
        defer {
            Console.activeConfiguration = currentlyActive
        }
        
        configuration = rawConf ?? currentlyActive
        Console.activeConfiguration = configuration

        let helpCommand = HelpCommand(otherCommands: _commands)
        for i in 0 ..< commands.count {
            commands[i].subCommands.insert(helpCommand, at: 0)
        }
        
        commands.append(helpCommand)
        self.commands = commands
        
    }
    
    
    public func run(arguments: [String], trimFirst: Bool = true) throws {
        var arguments = arguments
        if trimFirst {
            arguments = Array(arguments.dropFirst())
        }
        
        let currentlyActive = Console.activeConfiguration

        Console.activeConfiguration = configuration
        defer {
            Console.activeConfiguration = currentlyActive
        }
        
        guard !arguments.isEmpty else {
            throw CommandError.missingCommand
        }
        
        for cmd in commands {
            do {
                var currentData = try cmd.prepareData(arguments: arguments)
                
                var dataStack: [(Command, CommandData)] = [(cmd, currentData)]
                
                while let next = currentData.next {
                    currentData = try next.0.prepareData(arguments: next.1)
                    dataStack.append((next.0, currentData))
                    
                }
                
                var i = dataStack.count - 1
                
                
                while i > 0 {
                    let current = dataStack[i]
                    if let sub = current.0 as? SubCommand {
                        let shallRunParent = try sub.run(data: current.1, fromParent: dataStack[i - 1].0)
                        if !shallRunParent {
                            return; // not running further back - return
                        }
                    }

                    i -= 1;
                }
                // runs further back / no subcommands 
                try cmd.run(data: dataStack[0].1)

                
                return
            } catch CommandError.incorrectCommandName {
                // check other
            }
        }
        throw CommandError.commandNotFound(arguments[0])
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

