import XCTest
@testable import MoveToScreenDomain

final class EligibilityTests: XCTestCase {

    func test_a_visible_window_on_the_current_space_is_eligible() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 1),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )

        XCTAssertTrue(isEligible(window))
    }

    func test_a_minimized_window_on_the_current_space_is_eligible() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 2),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 800, height: 600),
            isMinimized: true,
            isFullscreen: false,
            isOnCurrentSpace: true
        )

        XCTAssertTrue(isEligible(window))
    }
}
