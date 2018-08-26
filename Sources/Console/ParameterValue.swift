//
//  ParameterValue.swift
//  Console
//
//  Created by Damian Malarczyk on 22/04/2018.
//  Copyright © 2018 Damian Malarczyk. All rights reserved.

import Foundation

public protocol ParameterValue: ValueCodable {

    static var valueType: ValueType { get }
}

extension Int: ParameterValue {

    public static var valueType: ValueType { return .int }
}

extension Double: ParameterValue {

    public static var valueType: ValueType { return .double }
}

extension String: ParameterValue {

    public static var valueType: ValueType { return .string }
}

extension Bool: ParameterValue {

    public static var valueType: ValueType { return .bool }
}

extension Array: ParameterValue where Element: ParameterValue {

    public static var valueType: ValueType { return .array(Element.valueType) }
}
