import XCTest
@testable import canvas_base

final class canvas_baseTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(canvas_base().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
