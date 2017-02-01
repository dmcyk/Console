#if os(Linux)

import XCTest
@testable import ConsoleTests

XCTMain([
    testCase(ConsoleTests.allTests),
    testCase(ValueTests.allTests)
])
#endif
