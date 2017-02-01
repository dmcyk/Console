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
    
    public var arguments: [String]
    private var commands: [Command]
    private var configuration: Configuration
    
    public init(arguments: [String], commands _commands: [Command], configuration rawConf: Console.Configuration? = nil, trimFirst: Bool = true) throws {
        var commands = _commands
        
        let currentlyActive = Console.activeConfiguration
        defer {
            Console.activeConfiguration = currentlyActive
        }
        
        configuration = rawConf ?? currentlyActive
        Console.activeConfiguration = configuration

        commands.append(HelpCommand(otherCommands: _commands))
        self.commands = commands
        
        if trimFirst {
            self.arguments = Array(arguments.suffix(from: 1))
        } else {
            self.arguments = arguments
        }
        
    }
    
    public func run() throws {
        let currentlyActive = Console.activeConfiguration

        Console.activeConfiguration = configuration
        defer {
            Console.activeConfiguration = currentlyActive
        }
        
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

