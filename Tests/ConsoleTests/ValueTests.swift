//
//  ValueTests.swift
//  ConsoleTests
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//
import XCTest
@testable import Console

class ValueTests: XCTestCase {

    static var allTests : [(String, (ValueTests) -> () throws -> Void)] {
        return [
            ("testExtract", testExtract),
            ("testExtractCompound", testExtractCompound),
            ("testDescription", testDescription),
            ("testComplexDescription", testComplexDescription),
            ("testNestedArrayDescription", testNestedArrayDescription),
            ("testInitialization", testInitialization)
        ]
    }
    
    func testExtract() throws {
        let _ = try CommandParameterType.extractValue(expected: .int, strValue: "1").intValue()
        let intVal = try CommandParameterType.extractValue(expected: .int, strValue: "9999").intValue()
        
        XCTAssert(intVal == 9999)
        
        let minus = try CommandParameterType.extractValue(expected: .int, strValue: "-125").intValue()
        
        XCTAssert(minus == -125)
        
        let _ = try CommandParameterType.extractValue(expected: .bool, strValue: "TRUE").boolValue()
        let _ = try CommandParameterType.extractValue(expected: .bool, strValue: "false").boolValue()
        let _ = try CommandParameterType.extractValue(expected: .string, strValue: "false").stringValue()
        let arr = try CommandParameterType.extractValue(expected: .array(.bool), strValue: "false,true,FALSE,1,0").arrayValue()
        
        XCTAssert(arr.count == 5)
        try XCTAssert(arr[0].boolValue() == false)
        try XCTAssert(arr[1].boolValue() == true)
        try XCTAssert(arr[2].boolValue() == false)
        try XCTAssert(arr[3].boolValue() == true)
        try XCTAssert(arr[4].boolValue() == false)
        
    }
    
    func testExtractCompound() throws {
        let val = try CommandParameterType.extractValue(expected: .array(.compound), strValue: "1,12.911,hello,true").arrayValue()
        
        XCTAssert(val[0].type == .int)
        XCTAssert(val[1].type == .double)
        XCTAssert(val[2].type == .string)
        XCTAssert(val[3].type == .bool)
    }

    func testDescription() {
        let string = Value.string("hehe")
        XCTAssert(string.description == "String(hehe)")

        let trueBool = Value.bool(true)
        XCTAssert(trueBool.description == "Bool(true)")

        let falseBool = Value.bool(false)
        XCTAssert(falseBool.description == "Bool(false)")

        let int = Value.int(10)
        XCTAssert(int.description == "Int(10)")

        let double = Value.double(10.0)
        XCTAssert(double.description == "Double(10.0)")
    }

    func testComplexDescription() {
        let strings = ["a", "b", "c"].map { Value.string($0) }
        let stringArray = Value.array(strings, .string)

        XCTAssert(stringArray.description == "Array<String>(a,b,c)")

        let singleStringArray = Value.array([.string("a")], .string)
        XCTAssert(singleStringArray.description == "Array<String>(a)")
    }

    func testNestedArrayDescription() {
        let strings = ["a", "b"].map { Value.string($0) }

        let array1: Value = .array(strings, .string)
        let array2 = array1

        let array: Value = .array([array1, array2], .array(.string))

        XCTAssert(array.description == "Array<Array<String>>((a,b),(a,b))")
    }

    func testInitialization() {
        let floatVal: Value = 10.0
        let intVal: Value = 10
        let boolValue: Value = true
        let stringValue: Value = "xx"
        let arrValue: Value = [floatVal, intVal, boolValue, stringValue]

        XCTAssert(floatVal.type == .double && floatVal.double == 10.0)
        XCTAssert(intVal.type == .int && intVal.integer == 10)
        XCTAssert(boolValue.type == .bool && boolValue.boolean == true)
        XCTAssert(stringValue.type == .string && stringValue.string == "xx")
        XCTAssert(arrValue.type == .array(.compound))

        let arr = try! arrValue.arrayValue()
        XCTAssert(arr[0] == floatVal)
        XCTAssert(arr[1] == intVal)
        XCTAssert(arr[2] == boolValue)
        XCTAssert(arr[3] == stringValue)
    }
}
