import XCTest
@testable import MoveToScreenDomain

final class DisplayContainingTests: XCTestCase {

    private let builtIn = DisplayInfo(
        id: DisplayId(rawValue: 1),
        name: "Built-in",
        frame: Frame(x: 0, y: 0, width: 1920, height: 1080)
    )

    private let external = DisplayInfo(
        id: DisplayId(rawValue: 2),
        name: "External",
        frame: Frame(x: 1920, y: 0, width: 2560, height: 1440)
    )

    func test_a_window_centered_on_built_in_returns_built_in() {
        let window = Frame(x: 100, y: 100, width: 800, height: 600)

        let result = displayContaining(frame: window, in: [builtIn, external])

        XCTAssertEqual(result, builtIn)
    }

    func test_a_window_centered_on_external_returns_external() {
        let window = Frame(x: 3000, y: 100, width: 800, height: 600)

        let result = displayContaining(frame: window, in: [builtIn, external])

        XCTAssertEqual(result, external)
    }

    func test_a_window_centered_outside_every_display_returns_nil() {
        let window = Frame(x: -5000, y: 0, width: 100, height: 100)

        let result = displayContaining(frame: window, in: [builtIn, external])

        XCTAssertNil(result)
    }
}
