import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
import MoveToScreenUseCases

/// Slice 2 ATDD — the outer-loop acceptance test for the "pick a
/// subset of running apps and move their windows onto one display"
/// journey. Drives the use case through in-memory fakes that stand in
/// for the real AX and NSScreen adapters; selection state is modelled
/// here as the explicit list the use case receives, matching what
/// MenuViewModel.moveSelected(to:) forwards from its in-memory Set.
final class MoveSelectedAppsToDisplayTests: XCTestCase {

    func test_only_selected_apps_windows_move_other_apps_windows_stay_put() throws {
        // GIVEN a 2-display rig…
        let builtIn = DisplayInfo(
            id: DisplayId(rawValue: 1),
            name: "Built-in Retina Display",
            frame: Frame(x: 0, y: 0, width: 1920, height: 1080)
        )
        let external = DisplayInfo(
            id: DisplayId(rawValue: 2),
            name: "Studio Display",
            frame: Frame(x: 1920, y: 0, width: 2560, height: 1440)
        )

        // …three apps each with a visible window on the external display.
        let terminal = AppId(rawValue: 100)
        let safari = AppId(rawValue: 101)
        let finder = AppId(rawValue: 102)

        let terminalWindow = visibleWindow(id: 10, app: terminal, anchorX: 2000, anchorY: 100)
        let safariWindow = visibleWindow(id: 20, app: safari, anchorX: 2100, anchorY: 200)
        let finderWindow = visibleWindow(id: 30, app: finder, anchorX: 2200, anchorY: 300)

        let accessibility = InMemoryAccessibilityClient()
        accessibility.windowsByApp[terminal] = [terminalWindow]
        accessibility.windowsByApp[safari] = [safariWindow]
        accessibility.windowsByApp[finder] = [finderWindow]

        let displayClient = InMemoryDisplayClient(displays: [builtIn, external])
        let useCase = MoveAppsWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )

        // WHEN the user selects only Terminal and Finder, then picks
        // "Send to → Built-in Retina Display".
        let result = try useCase.move(apps: [terminal, finder], to: builtIn.id)

        // THEN the two selected apps' windows moved…
        XCTAssertEqual(result.moved, 2)
        XCTAssertTrue(result.skipped.isEmpty)

        // …each landed within built-in's bounds…
        for call in accessibility.moveCalls {
            XCTAssertTrue(
                frameIsContained(call.frame, within: builtIn.frame),
                "moved window \(call.window) landed outside built-in: \(call.frame)"
            )
        }

        // …and Safari (unselected) was not touched at all.
        XCTAssertFalse(
            accessibility.moveCalls.contains(where: { $0.window == safariWindow.id }),
            "Safari's window should not have moved"
        )
    }

    // MARK: - Fixtures

    private func visibleWindow(id: UInt32, app: AppId, anchorX: Double, anchorY: Double) -> WindowSnapshot {
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: app,
            frame: Frame(x: anchorX, y: anchorY, width: 800, height: 600),
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )
    }

    private func frameIsContained(_ inner: Frame, within outer: Frame) -> Bool {
        let xFits = inner.origin.x >= outer.origin.x
            && inner.origin.x + inner.size.width <= outer.origin.x + outer.size.width
        let yFits = inner.origin.y >= outer.origin.y
            && inner.origin.y + inner.size.height <= outer.origin.y + outer.size.height
        return xFits && yFits
    }
}
