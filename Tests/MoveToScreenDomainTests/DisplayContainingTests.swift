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
}
