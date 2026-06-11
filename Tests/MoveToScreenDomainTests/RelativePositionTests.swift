import XCTest
@testable import MoveToScreenDomain

final class RelativePositionTests: XCTestCase {

    func test_a_window_whose_source_display_equals_its_destination_display_is_unchanged() {
        let display = Frame(x: 0, y: 0, width: 1920, height: 1080)
        let window = Frame(x: 100, y: 200, width: 800, height: 600)

        let result = relativePosition(
            window: window,
            sourceDisplay: display,
            destinationDisplay: display
        )

        XCTAssertEqual(result, window)
    }

    func test_a_window_at_the_left_edge_of_source_lands_at_the_left_edge_of_destination() {
        let source = Frame(x: 0, y: 0, width: 1000, height: 1000)
        let destination = Frame(x: 2000, y: 0, width: 500, height: 1000)
        let window = Frame(x: 0, y: 0, width: 100, height: 100)

        let result = relativePosition(
            window: window,
            sourceDisplay: source,
            destinationDisplay: destination
        )

        XCTAssertEqual(result.origin.x, 2000)
    }
}
