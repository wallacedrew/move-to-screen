import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
import MoveToScreenUseCases

/// Slice 2 ATDD — the outer-loop acceptance test for the
/// "move every running app's windows onto one display" journey.
/// Drives the use case through in-memory fakes that stand in for the
/// real AX and NSScreen adapters.
final class MoveEveryAppToOneDisplayTests: XCTestCase {

    func test_user_moves_every_apps_windows_onto_one_display() throws {
        // GIVEN a 3-display rig…
        let builtIn = DisplayInfo(
            id: DisplayId(rawValue: 1),
            name: "Built-in Retina Display",
            frame: Frame(x: 0, y: 0, width: 1920, height: 1080)
        )
        let leftExternal = DisplayInfo(
            id: DisplayId(rawValue: 2),
            name: "Studio Display",
            frame: Frame(x: -2560, y: 0, width: 2560, height: 1440)
        )
        let rightExternal = DisplayInfo(
            id: DisplayId(rawValue: 3),
            name: "DELL U2723QE",
            frame: Frame(x: 1920, y: 0, width: 2560, height: 1440)
        )

        // …and three apps with windows scattered across the displays,
        //    including one minimized window.
        let terminal = AppId(rawValue: 100)
        let safari = AppId(rawValue: 101)
        let finder = AppId(rawValue: 102)

        let terminalOnBuiltIn = visibleWindow(id: 10, app: terminal, anchorX: 100, anchorY: 100)
        let terminalOnRight = visibleWindow(id: 11, app: terminal, anchorX: 2050, anchorY: 200)
        let terminalMinimized = minimizedWindow(id: 12, app: terminal, anchorX: -2400, anchorY: 200)
        let safariOnLeft = visibleWindow(id: 20, app: safari, anchorX: -2300, anchorY: 100)
        let finderOnRight = visibleWindow(id: 30, app: finder, anchorX: 2200, anchorY: 300)

        let accessibility = InMemoryAccessibilityClient()
        accessibility.windowsByApp[terminal] = [terminalOnBuiltIn, terminalOnRight, terminalMinimized]
        accessibility.windowsByApp[safari] = [safariOnLeft]
        accessibility.windowsByApp[finder] = [finderOnRight]

        let displayClient = InMemoryDisplayClient(displays: [builtIn, leftExternal, rightExternal])
        let useCase = MoveAppsWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )

        // WHEN the user picks "Move all windows → Built-in Retina Display".
        let result = try useCase.move(apps: [terminal, safari, finder], to: builtIn.id)

        // THEN every one of the 5 windows was moved…
        XCTAssertEqual(result.moved, 5)
        XCTAssertTrue(result.skipped.isEmpty)

        // …each landed within the built-in display bounds…
        for call in accessibility.moveCalls {
            XCTAssertTrue(
                frameIsContained(call.frame, within: builtIn.frame),
                "moved window \(call.window) landed outside built-in: \(call.frame)"
            )
        }

        // …and the previously-minimized window was un-minimized before it moved.
        XCTAssertTrue(
            unminimizePrecededMove(of: terminalMinimized.id, in: accessibility.recordedCalls),
            "expected unminimize(\(terminalMinimized.id)) before move(\(terminalMinimized.id))"
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

    private func minimizedWindow(id: UInt32, app: AppId, anchorX: Double, anchorY: Double) -> WindowSnapshot {
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: app,
            frame: Frame(x: anchorX, y: anchorY, width: 800, height: 600),
            isMinimized: true,
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

    private func unminimizePrecededMove(
        of window: WindowId,
        in log: [InMemoryAccessibilityClient.Call]
    ) -> Bool {
        let unminimizeAt = log.firstIndex(of: .unminimize(window: window))
        let moveAt = log.firstIndex { call in
            if case .move(let id, _) = call, id == window { return true }
            return false
        }
        guard let unminimizeAt, let moveAt else { return false }
        return unminimizeAt < moveAt
    }
}
