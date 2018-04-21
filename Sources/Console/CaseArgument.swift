//
//  CaseArgument.swift
//  Console
//
//  Created by Damian Malarczyk on 21/04/2018.
//

import Foundation

public protocol CaseArgumentRawType: ValueCodable {

    static var valueType: ValueType { get }
}

extension String: CaseArgumentRawType {

    public static var valueType: ValueType { return .string }
}

extension Int: CaseArgumentRawType {

    public static var valueType: ValueType { return .int }
}

public struct CaseArgument<T: RawRepresentable>: ArgumentParameter where T.RawValue: CaseArgumentRawType {

    public enum Error: Swift.Error {

        case unkownCase(allowed: [String], got: String)
    }

    public let expected: ValueType
    public let `default`: Value?
    public let name: String
    public let shortForm: Character?
    public let description: [String]
    public let allowed: [Value]

    public init(_ name: String, _ allowed: [T], description: [String], `default`: T, shortForm: Character?) {
        self.name = name
        self.description = description
        self.default = `default`.rawValue.asValue
        self.expected = .array(T.RawValue.valueType)
        self.shortForm = shortForm
        self.allowed = allowed.map { $0.rawValue.asValue }
    }

    public func value(from argValue: String) throws -> Value? {
        let value = try CommandParameterType.extractValue(expected: expected, strValue: argValue)
        let arrValue = try value.arrayValue()

        try arrValue.forEach {
            guard allowed.contains($0) else {
                throw Error.unkownCase(allowed: allowed.map { $0.string }, got: argValue)
            }
        }

        return value
    }

    public func values(from data: CommandData) throws -> [T] {
        let val = try data.argumentValue(self).arrayValue().map { try T.RawValue(from: $0) }

        return val.compactMap { T.init(rawValue: $0) }
    }
}
