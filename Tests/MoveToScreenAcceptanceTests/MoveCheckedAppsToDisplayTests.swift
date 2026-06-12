import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
import MoveToScreenUseCases

/// Slice 2 v2 ATDD — the outer-loop acceptance test for the
/// "check a subset of apps on the main menu, then pick a display via
/// 'Move selected windows ▸'" journey. The selection state in the
/// view model is modelled here as the explicit list the use case
/// receives — MenuViewModel.moveSelected(to:) forwards Array(set) and
/// the use case operates on it.
final class MoveCheckedAppsToDisplayTests: XCTestCase {

    func test_only_the_checked_apps_windows_move_others_stay_put() throws {
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
        let finder = AppId(rawValue: 100)
        let activityMonitor = AppId(rawValue: 101)
        let terminal = AppId(rawValue: 102)

        let finderWindow = visibleWindow(id: 10, app: finder, anchorX: 2000, anchorY: 100)
        let activityWindow = visibleWindow(id: 20, app: activityMonitor, anchorX: 2100, anchorY: 200)
        let terminalWindow = visibleWindow(id: 30, app: terminal, anchorX: 2200, anchorY: 300)

        let accessibility = InMemoryAccessibilityClient()
        accessibility.windowsByApp[finder] = [finderWindow]
        accessibility.windowsByApp[activityMonitor] = [activityWindow]
        accessibility.windowsByApp[terminal] = [terminalWindow]

        let displayClient = InMemoryDisplayClient(displays: [builtIn, external])
        let useCase = MoveAppsWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )

        // WHEN the user checks Finder and Terminal on the main menu, then
        // picks "Move selected windows → Built-in Retina Display".
        let result = try useCase.move(apps: [finder, terminal], to: builtIn.id)

        // THEN the two checked apps' windows moved…
        XCTAssertEqual(result.moved, 2)
        XCTAssertTrue(result.skipped.isEmpty)

        // …each landed within built-in's bounds…
        for call in accessibility.moveCalls {
            XCTAssertTrue(
                frameIsContained(call.frame, within: builtIn.frame),
                "moved window \(call.window) landed outside built-in: \(call.frame)"
            )
        }

        // …and Activity Monitor (unchecked) was not touched at all.
        XCTAssertFalse(
            accessibility.moveCalls.contains(where: { $0.window == activityWindow.id }),
            "Activity Monitor's window should not have moved"
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
