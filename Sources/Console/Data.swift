//
//  Data.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public struct CommandData {
    
    private let parsed: [CommandParameterType: Value?]
    var next: (SubCommand, [String])?
    
    public static func verify(parameters: [CommandParameterType]) throws {
        var opts = [Option]()
        var args = [Argument]()
        
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
    
    
    public init(_ parameters: [CommandParameterType], input: [String], subcommands: [SubCommand]) throws {
        var parsing: [CommandParameterType: Value?] = [:]
        var toCheck = parameters
        
        try CommandData.verify(parameters: toCheck)
        
        for i in 0 ..< input.count {
            let currentInput = input[i]
            
            // subcommand // incorrect parameter
            if !currentInput.hasPrefix(Console.activeConfiguration.argumentPrefix)
                && !currentInput.hasPrefix(Console.activeConfiguration.optionPrefix) {
                // no prefix, so it must be a subcommand either wrong option 
                var sub: SubCommand! = nil
                for subCmd in subcommands {
                    if subCmd.name == currentInput {
                        sub = subCmd
                        break
                    }
                }
                if sub == nil {
                    // no arg, nor option prefix, subcommand not found
                    // either missing subcommand or missing prefix, can't say what user mean
                    // thus general error not making assumptions
                    throw CommandError.unexpectedCommandParameter(currentInput)
                    
                }
                next = (sub, Array(input[i ..< input.count]))
                break
            }
            
            var used: CommandParameterType?
            var indx: Int! = -1
            var val: String? = nil
            for j in 0 ..< toCheck.count {
                let current = toCheck[j]
                if let equalIndx = currentInput.characters.index(of: "=") {
                    
                    if current.consoleName == currentInput[..<equalIndx] {
                        used = current
                        
                        let after = currentInput.characters.index(after: equalIndx)
                        
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
                        val = String(currentInput.characters.dropFirst(shForm.characters.count))
                        // not handling empty strings, simply no input
                        if val!.characters.isEmpty {
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
            }
            
        }
        
        parsed = parsing
    }
    
    public func argumentValue(_ arg: Argument) throws -> Value {
        if let registered = parsed[.argument(arg)] {
            return registered!
        } else {
            throw CommandError.parameterNotAllowed(arg)
        }
        
    }
    
    public func argumentValue(_ name: String) throws -> Value {
        for r in parsed {
            switch r.key {
            case .argument(let arg):
                if arg.name == name {
                    return r.value!
                }
            default:
                break
            }
        }
        throw CommandError.parameterNotFound(name)
    }
    
    public func optionValue(_ opt: Option) throws -> Value? {
        if let registered = parsed[.option(opt)] {
            return registered
        } else {
            throw CommandError.parameterNotAllowed(opt)
        }
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
        throw CommandError.parameterNotFound(name)
    }
    
    public func flag(_ opt: Option) throws -> Bool {
        guard case .flag = opt.mode else {
            throw CommandError.requstedFlagOnValueOption
        }
        if let registered = parsed[.option(opt)] {
            if let reg = registered {
                if let boolValue = try? reg.boolValue() {
                    return boolValue
                } else {
                    throw CommandError.internalError
                }
            } else {
                return false
            }
        } else {
            throw CommandError.parameterNotAllowed(opt)
        }
    }
}
