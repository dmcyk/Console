//
//  ConsoleTests.swift
//  Console
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import XCTest
@testable import Console

class MockCommand: Command {
    var name: String = "mock"
    
    var parameters: [CommandParameterType] = []
    
    func run(data: CommandData) throws {
        
    }
}

class CommandTests: XCTestCase {
    
    let mock = MockCommand()
    let testArgument = Argument("test", expected: .string, default: "val", shortForm: "t")
    let testOption = Option("test", mode: .value(expected: .string, default: "optval"))
    
    static var allTests : [(String, (CommandTests) -> () throws -> Void)] {
        return [
            ("testArgumentDefault", testArgumentDefault),
            ("testArgumentMissingValue", testArgumentWithValue),
            ("testArgumentWithValue", testArgumentWithValue),
            ("testArgumentNotAllowed", testArgumentNotAllowed),
            ("testUnknownArgument", testUnknownArgument),
            ("testOptionParam", testOptionParam)
        ]
    }
    
    override func setUp() {
        mock.parameters.append(.argument(testArgument))
        mock.parameters.append(.option(testOption))
    }
    
    func testArgumentDefault() throws {
    
        let data = try mock.prepareData(arguments: ["mock"])
        
        try XCTAssert(data.argumentValue(testArgument).stringValue() == "val")
    }
    
    func testArgumentMissingValue() throws {
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "test"]))
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "t"]))
        
    }
    
    func testArgumentWithValue() throws {
        var data = try mock.prepareData(arguments: ["mock", "-test=some"])
        
        try XCTAssert(data.argumentValue(testArgument).stringValue() == "some")

        data = try mock.prepareData(arguments: ["mock", "-tsome"])
        
        try XCTAssert(data.argumentValue(testArgument).stringValue() == "some")
    }
    
    func testArgumentNotAllowed() throws {
        let data = try mock.prepareData(arguments: ["mock"])
        
        XCTAssertThrowsError(try data.argumentValue(Argument("test2", expected: .string)))
    }
    
    func testUnknownArgument() throws {
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "-test2=a"]))
    }
    
    func testOptionDefault() throws {
        let data = try mock.prepareData(arguments: ["mock"])
        
        try XCTAssert(data.optionValue(testOption)?.stringValue() == "optval")
    }
    
    func testOptionParam() throws {
        let nonDefaultOption = Option("some", description: nil, mode: .value(expected: .bool, default: nil))
        mock.parameters.append(.option(nonDefaultOption))
        
        defer {
            _ = mock.parameters.popLast()
        }
        
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "--some"])) // option has no default value, thus when used it must have value 
        
        let data = try mock.prepareData(arguments: ["mock", "--some=1"])
        
        try XCTAssert(data.optionValue(nonDefaultOption)?.boolValue() == true)
    }
    
    func testFlag() throws {
        let optionFlag = Option("aflag", mode: .flag)
        
        mock.parameters.append(.option(optionFlag))
        
        defer {
            _ = mock.parameters.popLast()
        }
        
        var data = try mock.prepareData(arguments: ["mock"])
        
        try XCTAssert(data.flag(optionFlag) == false)
        
        data = try mock.prepareData(arguments: ["mock", "--aflag"])
        
        try XCTAssert(data.flag(optionFlag) == true)
    }
    
    
    
}
