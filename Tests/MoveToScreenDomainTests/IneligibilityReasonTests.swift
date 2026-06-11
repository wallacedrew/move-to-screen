import XCTest
@testable import MoveToScreenDomain

final class IneligibilityReasonTests: XCTestCase {

    func test_an_eligible_window_has_no_ineligibility_reason() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 1),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )

        XCTAssertNil(ineligibilityReason(for: window))
    }

    func test_a_fullscreen_window_is_skipped_for_being_fullscreen() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 2),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 1920, height: 1080),
            isMinimized: false,
            isFullscreen: true,
            isOnCurrentSpace: true
        )

        XCTAssertEqual(ineligibilityReason(for: window), .fullscreen(window.id))
    }

    func test_a_window_on_another_space_is_skipped_for_being_off_space() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 3),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: false
        )

        XCTAssertEqual(ineligibilityReason(for: window), .onAnotherSpace(window.id))
    }

    func test_a_fullscreen_off_space_window_reports_fullscreen_first() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 4),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 1920, height: 1080),
            isMinimized: false,
            isFullscreen: true,
            isOnCurrentSpace: false
        )

        XCTAssertEqual(ineligibilityReason(for: window), .fullscreen(window.id))
    }
}
