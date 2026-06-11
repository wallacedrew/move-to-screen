import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
import MoveToScreenUseCases

/// Slice 1 ATDD — the outer-loop acceptance test for the
/// "consolidate scattered Terminal windows onto one display" journey.
/// Drives the use case through in-memory fakes that stand in for the
/// real AX and NSScreen adapters.
final class ConsolidateScatteredTerminalWindowsTests: XCTestCase {

    func test_user_consolidates_scattered_terminal_windows_onto_one_display() throws {
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

        // …and Terminal has 3 visible windows spread across the three displays,
        //    plus 1 minimized window anchored to the right external.
        let terminal = AppId(rawValue: 100)
        let onBuiltIn = visibleWindow(id: 10, app: terminal, anchorX: 100, anchorY: 100)
        let onLeft = visibleWindow(id: 11, app: terminal, anchorX: -2400, anchorY: 100)
        let onRight = visibleWindow(id: 12, app: terminal, anchorX: 2050, anchorY: 100)
        let minimized = minimizedWindow(id: 13, app: terminal, anchorX: 2200, anchorY: 200)

        let accessibility = InMemoryAccessibilityClient()
        accessibility.windowsByApp[terminal] = [onBuiltIn, onLeft, onRight, minimized]
        let displayClient = InMemoryDisplayClient(displays: [builtIn, leftExternal, rightExternal])
        let useCase = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )

        // WHEN the user picks Terminal → Built-in Retina Display.
        let result = try useCase.execute(app: terminal, destination: builtIn.id)

        // THEN all 4 windows were moved…
        XCTAssertEqual(result.moved, 4)
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
            unminimizePrecededMove(of: minimized.id, in: accessibility.recordedCalls),
            "expected unminimize(\(minimized.id)) before move(\(minimized.id))"
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
