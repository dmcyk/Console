//
//  ConsoleTests.swift
//  ConsoleTests
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//
import XCTest
@testable import Console


class ConsoleTests: XCTestCase {
    class MockCommand: Command {
        var name: String = "mock"
        var willRunSubcommandArg: Command?
        
        var parameters: [CommandParameterType] = []
        var subCommands: [Command] = []
        func run(data: CommandData) throws {
            
        }
        
        func willRunSubcommand(cmd: Command) {
            willRunSubcommandArg = cmd
        }
    }
    
    class Subcommand: Command {
        var runCache: CommandData? = nil
        var parameters: [CommandParameterType] = []
        var name: String = "subtest"
        
        func run(data: CommandData) throws {
            runCache = data
        }
    }
    
    static var allTests : [(String, (ConsoleTests) -> () throws -> Void)] {
        return [
            ("testSubcommand", testSubcommand)
        ]
    }
    
    var optionPrefix: String {
        return Console.activeConfiguration.optionPrefix
    }
    
    var argumentPrefix: String {
        return Console.activeConfiguration.argumentPrefix
    }
    
    let console = Console(commands: [])
    let mock = MockCommand()
    let testArgument = Argument("test", expected: .string, default: "val", shortForm: "t")

    override func setUp() {
        mock.parameters.append(.argument(testArgument))
        console.commands.append(mock)
    }
    
    func testSubcommand() throws {
        let sub = Subcommand()
        let subflag = Option("subflag", mode: .flag)
        
        sub.parameters.append(.option(subflag))
        
        mock.subCommands.append(sub)
        defer {
            mock.subCommands.removeLast()
        }
        
        try console.run(arguments: ["mock", "subtest", "\(optionPrefix)subflag"], trimFirst: false)
        
        XCTAssertNotNil(mock.willRunSubcommandArg)
        XCTAssertNotNil(sub.runCache)
        
        let data = sub.runCache!
        
        try XCTAssert(data.flag(subflag) == true)
    }
    
    
}
