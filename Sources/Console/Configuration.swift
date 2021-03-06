//
//  Configuration.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.
//

import Foundation

extension Console {
    
    static func defaultConfiguration() -> Configuration {
        return try! Configuration(argumentPrefix: "-", optionPrefix: "--")
    }
    
    public class Configuration {

        public enum Error: Swift.Error, CustomStringConvertible {

            case argumentOptionPrefixSameValue
            case argumentPrefixEmpty
            case optionPrefixEmpty
            
            public var description: String {
                switch self {
                case .argumentOptionPrefixSameValue:
                    return "Arguments and Options prefix must be different"
                case .argumentPrefixEmpty,
                .optionPrefixEmpty:
                    return "Parameter prefix may not be empty, no prefix syntax is reserved for commands"
                }
            }
            
        }

        let argumentPrefix: String
        let optionPrefix: String
        
        init(argumentPrefix: String, optionPrefix: String) throws {
            guard argumentPrefix != optionPrefix else {
                throw Error.argumentOptionPrefixSameValue
            }
            guard !argumentPrefix.isEmpty else {
                throw Error.argumentPrefixEmpty
            }
            guard !optionPrefix.isEmpty else {
                throw Error.optionPrefixEmpty
            }
            self.argumentPrefix = argumentPrefix
            self.optionPrefix = optionPrefix
        }
    }
}
