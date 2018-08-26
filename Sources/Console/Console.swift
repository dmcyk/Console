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

        commands.append(helpCommand)
        self.commands = commands
    }

    private func loopCommands(arguments: [String]) throws {
        guard !arguments.isEmpty else {
            throw CommandError.missingCommand
        }

        for cmd in commands {
            do {
                var currentData = try cmd.prepareData(arguments: arguments, parent: nil)

                var dataStack: [(Command, CommandData)] = [(cmd, currentData)]

                while let next = currentData.next {
                    currentData = try next.0.prepareData(arguments: next.1, parent: dataStack.last?.1)
                    dataStack.append((next.0, currentData))
                }

                var i = dataStack.count - 1

                while i > 0 {
                    let current = dataStack[i]
                    let parent = dataStack[i - 1]
                    i -= 1

                    guard parent.0.shouldRun(subcommand: current.0) else {
                        continue
                    }

                    if let sub = current.0 as? Subcommand {
                        let shouldRunParent = try sub.run(data: current.1, fromParent: parent.0)
                        if !shouldRunParent {
                            return
                        }
                    } else {
                        break
                    }
                }

                // runs further back / no subcommands
                let child: Command? = dataStack.count > 1 ? dataStack[1].0 : nil
                try cmd.run(data: dataStack[0].1, with: child)
                return
            } catch CommandError.incorrectCommandName {
                // check other
            }
        }
        throw CommandError.commandNotFound(arguments[0])
    }

    private func _run(arguments: [String], trimFirst: Bool) throws {
        var arguments = arguments
        if trimFirst {
            arguments = Array(arguments.dropFirst())
        }

        let currentlyActive = Console.activeConfiguration

        Console.activeConfiguration = configuration
        defer {
            Console.activeConfiguration = currentlyActive
        }

        try loopCommands(arguments: arguments)
    }

    public func run(arguments: [String], trimFirst: Bool = true) throws {
        try autoreleasepool {
            try _run(arguments: arguments, trimFirst: trimFirst)
        }
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
    public let argument: ArgumentParameter

    public init(error: ArgumentError, argument: ArgumentParameter) {
        self.error = error
        self.argument = argument
    }
}
