//
//  Parameter.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public enum CommandParameter {
    case option(Option)
    case argument(Argument)
    
    var consoleName: String {
        switch self {
        case .option(let opt):
            return opt.consoleName
        case .argument(let arg):
            return arg.consoleName
        }
    }
    
    static func optionConsoleName(forParameterName name: String) -> String {
        return Option.consolePrefix() + name
    }
    
    static func argumentConsoleName(forParameterName name: String) -> String {
        return Argument.consolePrefix() + name 
    }
    
}
