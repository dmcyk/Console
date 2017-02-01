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

        commands.append(HelpCommand(otherCommands: _commands))
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
                var data = try cmd.prepareData(arguments: arguments)
                try cmd.run(data: data)
                while let next = data.next {
                    data = try next.0.prepareData(arguments: next.1)
                    cmd.willRunSubcommand(cmd: next.0)
                    try next.0.run(data: data)
                }
                
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

