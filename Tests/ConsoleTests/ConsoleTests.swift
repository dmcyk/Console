//
//  ConsoleTests.swift
//  ConsoleTests
//
//  Created by Damian Malarczyk on 01.02.2017.
//
//
import XCTest
@testable import Console

enum SomeOption: String {

    case one, two, three
}

class ConsoleTests: XCTestCase {

    class MockCommand: Command {
        var name: String = "mock"
        
        var parameters: [CommandParameterType] = []
        var subCommands: [Command] = []

        func run(data: CommandData, with child: Command?) throws {

        }
        
    }
    
    class Subcommand: SubCommand {

        var runAsSubCache: CommandData? = nil
        var parameters: [CommandParameterType] = []
        var name: String = "subtest"
        var subCommands: [Command] = []

        func run(data: CommandData, with child: Command?) throws {
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
    let testArgument = Argument("test", default: "val", shortForm: "t")
    let testArgument2 = Argument("test2", default: "val2", shortForm: "x")
    let customArgument = CaseArgument<SomeOption>("someEnum", [.one, .two, .three], default: .custom([.one]))

    override func setUp() {
        mock.parameters.append(.argument(testArgument))
        mock.parameters.append(.argument(customArgument))
        console.commands.append(mock)
    }
    
    func testSubcommand() throws {
        let sub = Subcommand()
        let subflag = FlagOption("subflag")
        
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

    func testCustomArgumentType() {
        let data = try! CommandData([.argument(customArgument)], input: ["-someEnum=one"], subcommands: [], parent: nil)
        let typeSafe = try! customArgument.values(from: data)

        XCTAssert(typeSafe.count == 1 && typeSafe[0].rawValue == "one")
    }

    func testRecursiveDataReferences() {
        let parentData = try! CommandData([.argument(testArgument)], input: [], subcommands: [], parent: nil)
        let childData = try! CommandData([.argument(testArgument2)], input: [], subcommands: [], parent: parentData)

        XCTAssert(try! childData.argumentValue(testArgument) == "val")
        XCTAssert(try! childData.argumentValue(testArgument2) == "val2")
        XCTAssertThrowsError(try parentData.argumentValue(testArgument2))
        XCTAssert(try! parentData.argumentValue(testArgument) == "val")
    }
}
