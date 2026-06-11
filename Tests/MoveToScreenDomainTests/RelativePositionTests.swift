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
}
