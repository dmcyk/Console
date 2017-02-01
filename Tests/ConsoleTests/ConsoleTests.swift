import XCTest
@testable import Console

class ConsoleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Console().text, "Hello, World!")
    }


    static var allTests : [(String, (ConsoleTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
