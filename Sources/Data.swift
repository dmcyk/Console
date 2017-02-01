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
    var next: (Command, [String])?
    
    public init(_ parameters: [CommandParameterType], input: [String], subcommands: [Command]) throws {
        var parsing: [CommandParameterType: Value?] = [:]
        var toCheck = parameters
        
        for i in 0 ..< input.count {
            let currentInput = input[i]
            
            // subcommand // incorrect parameter
            if !currentInput.hasPrefix(Console.activeConfiguration.argumentPrefix)
                && !currentInput.hasPrefix(Console.activeConfiguration.optionPrefix) {
                // no prefix, so it must be a subcommand either wrong option 
                var sub: Command! = nil
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
                    throw CommandError.incorrectCommandOption(currentInput)
                    
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
                    
                    if current.consoleName == currentInput.substring(to: equalIndx) {
                        used = current
                        
                        let after = currentInput.characters.index(after: equalIndx)
                        
                        guard after != currentInput.endIndex else {
                            throw CommandError.missingValueAfterEqualSign // syntax error, if there's no value no = should be present
                        }
                        val = currentInput.substring(from: after)
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
                throw CommandError.incorrectCommandOption(currentInput)
            }
        }
        
        for remaining in toCheck {
            parsing[remaining] = try remaining.value(usedByUser: false, fromArgValue: nil)
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
    
    public func optionValue(_ opt: Option) throws -> Value? {
        if let registered = parsed[.option(opt)] {
            return registered
        } else {
            throw CommandError.parameterNotAllowed(opt)
        }
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
