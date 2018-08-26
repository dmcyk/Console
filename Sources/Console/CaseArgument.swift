//
//  CaseArgument.swift
//  Console
//
//  Created by Damian Malarczyk on 21/04/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public struct CaseArgument<T: RawRepresentable>: ArgumentParameter where T.RawValue: ParameterValue {

    public enum DefaultCases {

        case all
        case custom([T])
        case none
    }

    public enum Error: Swift.Error {

        case unkownCase(allowed: [String], got: String)
    }

    public let expected: ValueType
    public let `default`: Value?
    public let name: String
    public let shortForm: Character?
    public let description: [String]
    public let allowed: [Value]

    public var parameterType: CommandParameterType {
        return .argument(self)
    }

    public init(_ name: String, _ allowed: [T], `default`: DefaultCases = .all, description: [String] = [], shortForm: Character? = nil) {
        self.name = name

        let rawAllowed = allowed.map { $0.rawValue.asValue }
        self.description = description + [""] + rawAllowed.map { "- " + $0.string }

        switch `default` {
        case .all:
            self.default = .array(rawAllowed, T.RawValue.valueType)
        case .custom(let custom) where !custom.isEmpty:
            self.default = .array(custom.map { $0.rawValue.asValue }, T.RawValue.valueType)
        case .none, .custom:
            self.default = nil
        }
        self.expected = .array(T.RawValue.valueType)
        self.shortForm = shortForm
        self.allowed = rawAllowed
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
        let val = try data.argumentParameterValue(self).arrayValue()
            .map { try T.RawValue(from: $0) }

        return val.compactMap { T.init(rawValue: $0) }
    }
}
