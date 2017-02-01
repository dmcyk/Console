#if os(Linux)

import XCTest
@testable import ConsoleTests

XCTMain([
    testCase(CommandTests.allTests),
    testCase(ValueTests.allTests),
    testCase(ConsoleTests.allTests)
])
#endif
