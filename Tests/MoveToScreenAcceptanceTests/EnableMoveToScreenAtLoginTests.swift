import XCTest
import MoveToScreenPorts
import MoveToScreenTestSupport
import MoveToScreenUseCases

/// Slice 2 ATDD — the outer-loop acceptance test for the
/// "user enables MoveToScreen to launch at login (and later disables it)"
/// journey. Drives the use case through an in-memory `LoginItemClient`
/// that stands in for the real `SMAppService.mainApp` adapter.
final class EnableMoveToScreenAtLoginTests: XCTestCase {

    func test_user_enables_then_disables_open_at_login_from_the_menu() throws {
        // GIVEN the app has never been registered as a Login Item.
        let loginItem = InMemoryLoginItemClient(enabled: false)
        let toggle = ToggleOpenAtLogin(loginItem: loginItem)

        // WHEN the user opens the menu and turns 'Open at Login' on…
        XCTAssertFalse(loginItem.isEnabled(), "precondition: starts disabled")
        try toggle.execute()

        // THEN the app is registered to launch at login.
        XCTAssertTrue(loginItem.isEnabled())
        XCTAssertEqual(loginItem.recordedCalls, [.register])

        // WHEN the user later opens the menu and turns 'Open at Login' off…
        try toggle.execute()

        // THEN the app is unregistered.
        XCTAssertFalse(loginItem.isEnabled())
        XCTAssertEqual(loginItem.recordedCalls, [.register, .unregister])
    }
}
