import XCTest

import scaffoldTests

var tests = [XCTestCaseEntry]()
tests += scaffoldTests.allTests()
XCTMain(tests)
