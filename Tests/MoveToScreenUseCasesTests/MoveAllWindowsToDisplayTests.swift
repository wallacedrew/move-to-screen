import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
@testable import MoveToScreenUseCases

final class MoveAllWindowsToDisplayTests: XCTestCase {

    private var accessibility: InMemoryAccessibilityClient!
    private var displayClient: InMemoryDisplayClient!
    private var useCase: MoveAllWindowsToDisplay!

    private let terminal = AppId(rawValue: 100)
    private let safari = AppId(rawValue: 101)
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

    override func setUp() {
        super.setUp()
        accessibility = InMemoryAccessibilityClient()
        displayClient = InMemoryDisplayClient(displays: [builtIn, external])
        useCase = MoveAllWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
    }

    func test_with_no_running_apps_no_windows_are_moved() throws {
        accessibility.appsWithEligibleWindows = []

        let result = try useCase.move(to: builtIn.id)

        XCTAssertEqual(result, MoveResult(moved: 0, skipped: []))
    }

    func test_a_single_apps_visible_window_is_moved_to_the_destination() throws {
        register(app: terminal, displayName: "Terminal")
        accessibility.windowsByApp[terminal] = [makeVisibleWindow(id: 10, owner: terminal, on: external)]

        _ = try useCase.move(to: builtIn.id)

        XCTAssertEqual(accessibility.moveCalls.count, 1)
    }

    func test_the_moved_count_sums_the_moved_windows_across_every_app() throws {
        register(app: terminal, displayName: "Terminal")
        register(app: safari, displayName: "Safari")
        accessibility.windowsByApp[terminal] = [
            makeVisibleWindow(id: 10, owner: terminal, on: external),
            makeVisibleWindow(id: 11, owner: terminal, on: external),
        ]
        accessibility.windowsByApp[safari] = [
            makeVisibleWindow(id: 20, owner: safari, on: external),
        ]

        let result = try useCase.move(to: builtIn.id)

        XCTAssertEqual(result.moved, 3)
    }

    func test_a_skipped_window_from_one_app_appears_in_the_aggregated_skip_list() throws {
        register(app: terminal, displayName: "Terminal")
        register(app: safari, displayName: "Safari")
        let fullscreen = makeFullscreenWindow(id: 10, owner: terminal, on: external)
        accessibility.windowsByApp[terminal] = [fullscreen]
        accessibility.windowsByApp[safari] = [makeVisibleWindow(id: 20, owner: safari, on: external)]

        let result = try useCase.move(to: builtIn.id)

        XCTAssertEqual(result.skipped, [.fullscreen(fullscreen.id)])
    }

    func test_a_failing_apps_move_does_not_prevent_the_next_apps_move() throws {
        register(app: terminal, displayName: "Terminal")
        register(app: safari, displayName: "Safari")
        let failing = makeVisibleWindow(id: 10, owner: terminal, on: external)
        let succeeding = makeVisibleWindow(id: 20, owner: safari, on: external)
        accessibility.windowsByApp[terminal] = [failing]
        accessibility.windowsByApp[safari] = [succeeding]
        accessibility.moveErrorByWindow[failing.id] = TestError.move

        _ = try useCase.move(to: builtIn.id)

        XCTAssertEqual(accessibility.moveCalls.map(\.window), [succeeding.id])
    }

    func test_an_unknown_destination_display_results_in_no_moves() throws {
        register(app: terminal, displayName: "Terminal")
        accessibility.windowsByApp[terminal] = [makeVisibleWindow(id: 10, owner: terminal, on: external)]

        let result = try useCase.move(to: DisplayId(rawValue: 999))

        XCTAssertEqual(result.moved, 0)
    }

    private enum TestError: String, Error {
        case move
    }

    // MARK: - Fixtures

    private func register(app: AppId, displayName: String) {
        accessibility.appsWithEligibleWindows.append(
            AppDescription(id: app, displayName: displayName, bundleIdentifier: nil)
        )
    }

    private func makeVisibleWindow(id: UInt32, owner: AppId, on display: DisplayInfo) -> WindowSnapshot {
        let frame = Frame(
            x: display.frame.origin.x + 50,
            y: display.frame.origin.y + 50,
            width: 600,
            height: 400
        )
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: owner,
            frame: frame,
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )
    }

    private func makeFullscreenWindow(id: UInt32, owner: AppId, on display: DisplayInfo) -> WindowSnapshot {
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: owner,
            frame: display.frame,
            isMinimized: false,
            isFullscreen: true,
            isOnCurrentSpace: true
        )
    }
}
