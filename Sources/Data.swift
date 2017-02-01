//
//  Data.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public struct CommandData {
    private var arguments: [String: Argument]
    private var options: [String: Option]
    var input: [String]
    
    public init(_ parameters: [CommandParameter], input: [String]) throws {
        arguments = [:]
        options = [:]
        self.input = input
        
        for param in parameters {
            switch param {
            case .argument(let arg):
                _ = try arg.value(input)
                arguments[arg.name] = arg
                
            case .option(let opt):
                options[opt.name] = opt
            }
        }
    }
    
    
    public func argumentValue(_ argName: String) throws -> Value {
        
        guard let argument = arguments[argName] else {
            throw CommandError.parameterNameNotAllowed
        }
        return try argument.value(input)
        
    }
    
    public func flag(_ name: String) throws -> Bool {
        guard let option = options[name] else {
            throw CommandError.parameterNameNotAllowed
        }
        return option.flag(input)
    }
    
    public func optionValue(_ name: String) throws -> Value? {
        guard let option = options[name] else {
            throw CommandError.parameterNameNotAllowed
        }
        return try option.value(input)
    }
}
