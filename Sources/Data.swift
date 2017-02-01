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
    
    public init(_ parameters: [CommandParameterType], input: [String], subcommands: [Command]) throws {
        var parsing: [CommandParameterType: Value?] = [:]
        var toCheck = parameters
        
        for i in 0 ..< input.count {
            let currentInput = input[i]
            for sub in subcommands {
                if currentInput == sub.name {
                    // TODO subcommand
                }
            }
            
            var used: CommandParameterType?
            var indx: Int! = -1
            var val: String? = nil
            for j in 0 ..< toCheck.count {
                let current = toCheck[j]
                if currentInput.hasPrefix(current.consoleName) {
                    used = current
                    
                    let val: String?
                    if let equalIndx = currentInput.characters.index(of: "=") {
                        val = currentInput.substring(from: equalIndx)
                        guard !val!.characters.isEmpty else {
                            throw CommandError.missingValueAfterEqualSign // syntax error, if there's no value no = should be present
                        }
                    }
                    break
                } else if let shForm = current.consoleShForm {
                    if currentInput.hasPrefix(shForm) {
                        used = current
                        val = String(currentInput.characters.dropFirst(shForm.characters.count))
                        if val!.characters.isEmpty {
                            val = nil
                        }
                        break
                    }
                }
                if let _ = used {
                    indx = j
                }
            }
            
            if let usedParam = used {
                parsing[usedParam] = try usedParam.value(usedByUser: true, fromArgValue: val)
                toCheck.remove(at: indx)
            } else {
                throw CommandError.unregonizedInput(currentInput)
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
