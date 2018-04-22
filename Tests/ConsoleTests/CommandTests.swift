//
//  CommandTests.swift
//  ConsoleTests
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//

import XCTest
@testable import Console

class CommandTests: XCTestCase {
    class MockCommand: Command {
        var name: String = "mock"
        
        var parameters: [CommandParameterType] = []
        var subCommands: [SubCommand] = []
        func run(data: CommandData, with child: SubCommand?) throws {

        }
    }
    
    let mock = MockCommand()
    let testArgument = Argument("test", default: "val", shortForm: "t")
    let testOption = Option("test", mode: .value(expected: .string, default: "optval"))
    
    static var allTests : [(String, (CommandTests) -> () throws -> Void)] {
        return [
            ("testArgumentDefault", testArgumentDefault),
            ("testArgumentMissingValue", testArgumentWithValue),
            ("testArgumentWithValue", testArgumentWithValue),
            ("testArgumentNotAllowed", testArgumentNotAllowed),
            ("testUnknownArgument", testUnknownArgument),
            ("testOptionDefault", testOptionDefault),
            ("testOptionParam", testOptionParam),
            ("testFlag", testFlag)
        ]
    }
    
    var optionPrefix: String {
        return Console.activeConfiguration.optionPrefix
    }
    
    var argumentPrefix: String {
        return Console.activeConfiguration.argumentPrefix
    }
    
    override func setUp() {
        mock.parameters.append(.argument(testArgument))
        mock.parameters.append(.option(testOption))

    }
    
    func testArgumentDefault() throws {
    
        let data = try mock.prepareData(arguments: ["mock"])
        
        try XCTAssert(data.argumentValue(testArgument) == "val")
    }
    
    func testArgumentMissingValue() throws {
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "test"]))
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "t"]))
        
    }
    
    func testArgumentWithValue() throws {
        var data = try mock.prepareData(arguments: ["mock", "\(argumentPrefix)test=some"])
        
        try XCTAssert(data.argumentValue(testArgument) == "some")

        data = try mock.prepareData(arguments: ["mock", "\(argumentPrefix)tsome"])
        
        try XCTAssert(data.argumentValue(testArgument) == "some")
    }
    
    func testArgumentNotAllowed() throws {
        let data = try mock.prepareData(arguments: ["mock"])
        
        XCTAssertThrowsError(try data.argumentValue(Argument<String>("test2")))
    }
    
    func testUnknownArgument() throws {
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "\(argumentPrefix)test2=a"]))
    }
    
    func testOptionDefault() throws {
        let data = try mock.prepareData(arguments: ["mock"])
        
        try XCTAssert(data.optionValue(testOption)?.stringValue() == "optval")
    }
    
    func testOptionParam() throws {
        let nonDefaultOption = Option("some", description: [], mode: .value(expected: .bool, default: nil))
        mock.parameters.append(.option(nonDefaultOption))
        
        defer {
            _ = mock.parameters.popLast()
        }
        
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock", "\(optionPrefix)some"])) // option has no default value, thus when used it must have value
        
        let data = try mock.prepareData(arguments: ["mock", "\(optionPrefix)some=1"])
        
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
        
        data = try mock.prepareData(arguments: ["mock", "\(optionPrefix)aflag"])
        
        try XCTAssert(data.flag(optionFlag) == true)
    }
    
    func testNameCollision() {
        let option1 = Option("opt", mode: .flag)
        let option2 = Option("opt", mode: .value(expected: .string, default: "abcd"))
        
        mock.parameters.append(.option(option1))
        mock.parameters.append(.option(option2))
        
        defer {
            mock.parameters.removeLast(2)
        }
        
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock"]))
    }
    
    func testShFormCollision() {
        let arg1 = Argument("argx", default: "ee", shortForm: "a")
        let arg2 = Argument("argy", default: 10, shortForm: "a")
        
        mock.parameters.append(.argument(arg1))
        mock.parameters.append(.argument(arg2))
        
        defer {
            mock.parameters.removeLast(2)
        }
        
        XCTAssertThrowsError(try mock.prepareData(arguments: ["mock"]))
    }
}
