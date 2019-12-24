import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(canvas_baseTests.allTests)
    ]
}
#endif
