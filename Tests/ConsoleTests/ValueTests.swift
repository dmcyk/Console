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
            ("testExtractCompound", testExtractCompound)
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
    
    
}
