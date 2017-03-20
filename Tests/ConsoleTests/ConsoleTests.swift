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
        
        var parameters: [CommandParameterType] = []
        var subCommands: [SubCommand] = []
        func run(data: CommandData) throws {
            
        }
        
    }
    
    class Subcommand: SubCommand {
        var runAsSubCache: CommandData? = nil
        var parameters: [CommandParameterType] = []
        var name: String = "subtest"
        var subCommands: [SubCommand] = []

        func run(data: CommandData) throws {
        }
        
        func run(data: CommandData, fromParent: Command) throws -> Bool {
            runAsSubCache = data
            
            return false
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
        
        XCTAssertNotNil(sub.runAsSubCache)
        
        let data = sub.runAsSubCache!
        
        try XCTAssert(data.flag(subflag) == true)
    }
    
    
}
