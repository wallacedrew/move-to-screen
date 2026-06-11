import XCTest
@testable import MoveToScreenDomain

/// Microtests pinning the pure compute phase of moving a window to a
/// destination display: ineligibility check, source-display lookup,
/// proportional-frame computation. Side-effecting move/unminimize is
/// the use case's job — `placementPlan` itself is pure.
final class PlacementPlanTests: XCTestCase {

    func test_an_ineligible_window_is_planned_to_skip() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 1),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 0, y: 0, width: 1920, height: 1080),
            isMinimized: false,
            isFullscreen: true,
            isOnCurrentSpace: true
        )
        let destination = display(id: 1, x: 0)

        XCTAssertEqual(
            placementPlan(for: window, in: [destination], destination: destination),
            .skip(.fullscreen(window.id))
        )
    }

    func test_a_window_off_every_known_display_is_planned_to_skip() {
        let window = WindowSnapshot(
            id: WindowId(rawValue: 2),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: -5000, y: -5000, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )
        let onlyDisplay = display(id: 1, x: 0)

        XCTAssertEqual(
            placementPlan(for: window, in: [onlyDisplay], destination: onlyDisplay),
            .skip(.sourceDisplayNotFound(window.id))
        )
    }

    func test_an_eligible_window_is_planned_to_be_placed_at_its_relative_destination_frame() {
        let source = display(id: 1, x: 0)
        let destination = display(id: 2, x: 1920)
        let window = WindowSnapshot(
            id: WindowId(rawValue: 3),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 100, y: 100, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )

        let expected = relativePosition(
            window: window.frame,
            sourceDisplay: source.frame,
            destinationDisplay: destination.frame
        )

        XCTAssertEqual(
            placementPlan(for: window, in: [source, destination], destination: destination),
            .place(at: expected)
        )
    }

    func test_a_minimized_eligible_window_is_planned_to_be_placed() {
        let source = display(id: 1, x: 0)
        let destination = display(id: 2, x: 1920)
        let window = WindowSnapshot(
            id: WindowId(rawValue: 4),
            ownerApp: AppId(rawValue: 100),
            frame: Frame(x: 200, y: 200, width: 800, height: 600),
            isMinimized: true,
            isFullscreen: false,
            isOnCurrentSpace: true
        )

        let plan = placementPlan(for: window, in: [source, destination], destination: destination)

        guard case .place = plan else {
            XCTFail("expected .place, got \(plan)")
            return
        }
    }

    // MARK: - Fixtures

    private func display(id: UInt32, x: Double) -> DisplayInfo {
        return DisplayInfo(
            id: DisplayId(rawValue: id),
            name: "Display \(id)",
            frame: Frame(x: x, y: 0, width: 1920, height: 1080)
        )
    }
}
