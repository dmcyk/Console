//
//  Data.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.
//

import Foundation

public struct CommandData {
    
    private let parsed: [CommandParameterType: Value]
    private var _parent: Any?
    var parent: CommandData? {
        return _parent as? CommandData
    }
    var next: (Command, [String])?
    
    public static func verify(parameters: [CommandParameterType]) throws {
        var opts = [OptionParameter]()
        var args = [ArgumentParameter]()
        
        for p in parameters {
            switch p {
            case .argument(let arg):
                for added in args {
                    if arg.name == added.name  {
                        throw CommandError.nameCollision(arg.name)
                    } else if let lhs = arg.shortForm, let rsh = added.shortForm, lhs == rsh {
                        throw CommandError.shortFormCollision(lhs)
                    }
                }
                args.append(arg)
            case .option(let opt):
                for added in opts {
                    if opt.name == added.name {
                        throw CommandError.nameCollision(opt.name)
                    } else if let lhs = opt.shortForm, let rhs = added.shortForm, lhs == rhs {
                        throw CommandError.shortFormCollision(lhs)
                    }
                }
                opts.append(opt)
            }
        }
    }
    
    
    public init(_ parameters: [CommandParameterType], input: [String], subcommands: [Command], parent: CommandData?) throws {
        self._parent = parent

        var parsing: [CommandParameterType: Value] = [:]
        var toCheck = parameters
        
        try CommandData.verify(parameters: toCheck)

        for i in 0 ..< input.count {
            let currentInput = input[i]
            
            // subcommand // incorrect parameter
            if !currentInput.hasPrefix(Console.activeConfiguration.argumentPrefix)
                && !currentInput.hasPrefix(Console.activeConfiguration.optionPrefix) {
                // no prefix, so it must be a subcommand either wrong option 
                var sub: Command? = nil
                for subcmd in subcommands {
                    if subcmd.name == currentInput {
                        sub = subcmd
                        break
                    }
                }

                if let subcommand = sub {
                    next = (subcommand, Array(input[i ..< input.count]))
                    break
                } else {
                    // no arg, nor option prefix, subcommand not found
                    // either missing subcommand or missing prefix, can't say what user mean
                    // thus general error not making assumptions
                    throw CommandError.unexpectedCommandParameter(currentInput)
                }
            }
            
            var used: CommandParameterType?
            var indx: Int! = -1
            var val: String? = nil
            for j in 0 ..< toCheck.count {
                let current = toCheck[j]
                if let equalIndx = currentInput.index(of: "=") {
                    
                    if current.consoleName == currentInput[..<equalIndx] {
                        used = current
                        
                        let after = currentInput.index(after: equalIndx)
                        
                        guard after != currentInput.endIndex else {
                            throw CommandError.missingValueAfterEqualSign // syntax error, if there's no value no = should be present
                        }
                        val = String(currentInput[after...])
                        indx = j
                        
                        break
                    }
                    
                } else if currentInput == current.consoleName {
                    // flag or option with default value
                    // if properly used
                    used = current
                    val = nil 
                    indx = j
                    break
                } else if let shForm = current.consoleShForm {
                    // short form
                    if currentInput.hasPrefix(shForm) {
                        used = current
                        val = String(currentInput.dropFirst(shForm.count))
                        // not handling empty strings, simply no input
                        if val!.isEmpty {
                            val = nil
                        }
                        indx = j
                        break
                    }
                }
                
            }

            if let usedParam = used {
                parsing[usedParam] = try usedParam.value(usedByUser: true, fromArgValue: val)
                toCheck.remove(at: indx)
            } else {
                throw CommandError.unexpectedCommandParameter(currentInput)
            }
        }
        
        for remaining in toCheck {
            if let val = try? remaining.value(usedByUser: false, fromArgValue: nil) {
                parsing[remaining] = val
            } else {
                throw CommandError.missingOptionValue(remaining)
            }
        }

        self.parsed = parsing
    }
    
    public func argumentParameterValue(_ arg: ArgumentParameter) throws -> Value {
        if let registered = parsed[.argument(arg)] {
            return registered
        }

        if let parentValue = parent.flatMap({ try? $0.argumentParameterValue(arg) }) {
            return parentValue
        }

        throw CommandError.parameterNotAllowed(arg)
    }

    public func argumentValue<T>(_ arg: Argument<T>) throws -> T {
        if let entry = parsed[.argument(arg)] {
            return try T(from: entry)
        }

        if let parentValue = parent.flatMap({ try? $0.argumentValue(arg) }) {
            return parentValue
        }

        throw CommandError.parameterNotAllowed(arg)
    }
    
    public func argumentParameterValue(_ name: String) throws -> Value {
        for r in parsed {
            switch r.key {
            case .argument(let arg):
                if arg.name == name {
                    return r.value
                }
            default:
                break
            }
        }

        if let parentValue = parent.flatMap({ try? $0.argumentParameterValue(name) }) {
            return parentValue
        }

        throw CommandError.parameterNotFound(name)
    }
    
    public func optionValue<T>(_ opt: Option<T>) throws -> T? {
        if let registered = parsed[.option(opt)] {
            return try T(from: registered)
        }

        if let parentValue = parent.flatMap({ try? $0.optionValue(opt) }) {
            return parentValue
        }

        throw CommandError.parameterNotAllowed(opt)
    }
    
    public func optionValue(_ name: String) throws -> Value? {
        for r in parsed {
            switch r.key {
            case .option(let opt):
                if opt.name == name {
                    return r.value
                }
                
            default:
                break
            }
        }

        if let parentValue = parent.flatMap({ try? $0.optionValue(name) }) {
            return parentValue
        }

        throw CommandError.parameterNotFound(name)
    }
    
    public func flag(_ opt: FlagOption) throws -> Bool {
        if let registered = parsed[.option(opt)] {
            if let boolValue = try? registered.boolValue() {
                return boolValue
            } else {
                throw CommandError.internalError
            }
        }

        if let parentValue = parent.flatMap({ try? $0.flag(opt) }) {
            return parentValue
        }

        throw CommandError.parameterNotAllowed(opt)
    }
}
