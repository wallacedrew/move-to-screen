import XCTest
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenTestSupport
@testable import MoveToScreenUseCases

final class MoveAppWindowsToDisplayTests: XCTestCase {

    private var accessibility: InMemoryAccessibilityClient!
    private var displayClient: InMemoryDisplayClient!
    private var useCase: MoveAppWindowsToDisplay!

    private let terminal = AppId(rawValue: 100)
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
        useCase = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
    }

    func test_a_visible_window_on_external_is_moved_to_the_built_in_display() throws {
        let window = makeVisibleWindow(id: 10, on: external)
        accessibility.windowsByApp[terminal] = [window]

        _ = try useCase.execute(app: terminal, destination: builtIn.id)

        XCTAssertEqual(accessibility.moveCalls.count, 1)
    }

    func test_a_minimized_window_is_unminimized_before_being_moved() throws {
        let minimized = makeMinimizedWindow(id: 20, anchoredTo: external)
        accessibility.windowsByApp[terminal] = [minimized]

        _ = try useCase.execute(app: terminal, destination: builtIn.id)

        let expected: [InMemoryAccessibilityClient.Call] = [
            .unminimize(window: minimized.id),
            .move(window: minimized.id, frame: accessibility.moveCalls[0].frame),
        ]
        XCTAssertEqual(accessibility.recordedCalls, expected)
    }

    // MARK: - Fixtures

    private func makeVisibleWindow(id: UInt32, on display: DisplayInfo) -> WindowSnapshot {
        let frame = Frame(
            x: display.frame.origin.x + 50,
            y: display.frame.origin.y + 50,
            width: 600,
            height: 400
        )
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: terminal,
            frame: frame,
            isMinimized: false,
            isFullscreen: false,
            isOnCurrentSpace: true
        )
    }

    private func makeMinimizedWindow(id: UInt32, anchoredTo display: DisplayInfo) -> WindowSnapshot {
        let frame = Frame(
            x: display.frame.origin.x + 50,
            y: display.frame.origin.y + 50,
            width: 600,
            height: 400
        )
        return WindowSnapshot(
            id: WindowId(rawValue: id),
            ownerApp: terminal,
            frame: frame,
            isMinimized: true,
            isFullscreen: false,
            isOnCurrentSpace: true
        )
    }
}
