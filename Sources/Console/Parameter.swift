//
//  Parameter.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import Foundation

public protocol CommandParameter {

    var name: String { get }
    var shortForm: Character? { get }
    var description: [String] { get }
    
    static func consolePrefix() -> String
    /// called once verified that fromArgument already matches given parameter name
    func value(usedByUser: Bool, fromArgValue: String?) throws -> Value?
}

extension CommandParameter {

    var consoleName: String {
        return "\(Self.consolePrefix())\(name)"
    }
    
    var consoleShForm: String? {
        if let shForm = shortForm {
            return "\(Self.consolePrefix())\(shForm)"
        }
        return nil
    }
}

func cmpParam(_ lhs: CommandParameter, _ rhs: CommandParameter) -> Bool {
    if lhs.name == rhs.name {
        return true
    }
    if let lshname = lhs.shortForm, let rshname = rhs.shortForm {
        return lshname == rshname
    }
    return false
}

public enum CommandParameterType: Equatable, Hashable {

    case option(Option)
    case argument(ArgumentParameter)
    
    public var hashValue: Int {
        let param: CommandParameter
        switch self {
        case .option(let opt):
            param = opt
        case .argument(let arg):
            param = arg
        }
        let shForm = param.shortForm
        return "\(param.consoleName)_\(shForm != nil ? "\(shForm!)" : "")".hashValue
        
    }
    
    var consoleName: String {
        switch self {
        case .option(let opt):
            return opt.consoleName
        case .argument(let arg):
            return arg.consoleName
        }
    }
    
    var consoleShForm: String? {
        switch self {
        case .option(let opt):
            return opt.consoleShForm
        case .argument(let arg):
            return arg.consoleShForm
        }
    }
    
    public static func ==(_ lhs: CommandParameterType, _ rhs: CommandParameterType) -> Bool {
        switch (lhs, rhs) {
        case (.option(let lopt), .option(let ropt)):
            return cmpParam(lopt, ropt)
        case (.argument(let larg), .argument(let rarg)):
            return cmpParam(larg, rarg)
        default:
            return false
        }
    }
    
    func value(usedByUser: Bool, fromArgValue: String?) throws -> Value? {
        switch self {
        case .argument(let arg):
            return try arg.value(usedByUser: usedByUser, fromArgValue: fromArgValue)
        case .option(let opt):
            return try opt.value(usedByUser: usedByUser, fromArgValue: fromArgValue)
        }
    }
    
}

