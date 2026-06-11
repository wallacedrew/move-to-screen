import XCTest

// Slice 1 ATDD — the outer loop test.
// Stays RED until the MoveAppWindowsToDisplay use case lands in step 7.
// Excluded from the pre-commit fast suite via `swift test --skip` (see script/pre-commit).
//
// When the use case is wired through in-memory fakes, replace this file's body
// with the Given / When / Then assertions described in the comment below.

final class ConsolidateScatteredTerminalWindowsTests: XCTestCase {

    func test_user_consolidates_scattered_terminal_windows_onto_one_display() throws {
        // GIVEN  Terminal has 3 visible windows + 1 minimized,
        //        spread across 3 connected displays.
        // WHEN   the user picks Terminal → "Built-in Retina Display"
        //        through the MoveAppWindowsToDisplay use case.
        // THEN   all 4 windows land on the built-in display,
        //        each at its source's proportional position on the new display,
        //        and the previously-minimized window has been un-minimized first.
        XCTFail(
            "Slice 1 ATDD pending — MoveAppWindowsToDisplay use case not yet implemented."
        )
    }
}
