//
//  ValueConvertible.swift
//  Console
//
//  Created by Damian Malarczyk on 21/04/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public protocol ValueEncodable {

    var asValue: Value { get }
}

public protocol ValueDecodable {

    init(from value: Value) throws
}

public typealias ValueCodable = ValueEncodable & ValueDecodable

extension String: ValueCodable {

    public var asValue: Value {
        return .string(self)
    }

    public init(from value: Value) throws {
        self = try value.stringValue()
    }
}

extension Int: ValueCodable {

    public var asValue: Value {
        return .int(self)
    }

    public init(from value: Value) throws {
        self = try value.intValue()
    }
}

extension Bool: ValueCodable {

    public var asValue: Value {
        return .bool(self)
    }

    public init(from value: Value) throws {
        self = try value.boolValue()
    }
}

extension Double: ValueCodable {

    public var asValue: Value {
        return .double(self)
    }

    public init(from value: Value) throws {
        self = try value.doubleValue()
    }
}

extension Array: ValueEncodable where Element: ValueEncodable {

    public var asValue: Value {
        return Value.dynamicArray(from: self.map { $0.asValue })
    }
}

extension Array: ValueDecodable where Element: ValueDecodable {

    public init(from value: Value) throws {
        let arrValue = try value.arrayValue()

        self = try arrValue.map { try Element.init(from: $0) }
    }
}
