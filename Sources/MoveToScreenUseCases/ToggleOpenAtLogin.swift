import MoveToScreenPorts

/// Flips the "open MoveToScreen at login" state. Reads the current
/// state from the port and dispatches the matching side — register
/// when off, unregister when on. Owns the toggle semantics so the
/// menu can stay dumb (call execute, re-read isEnabled for the check
/// mark).
public struct ToggleOpenAtLogin {

    private let loginItem: LoginItemClient

    public init(loginItem: LoginItemClient) {
        self.loginItem = loginItem
    }

    public func execute() throws {
        if loginItem.isEnabled() {
            try loginItem.unregister()
        } else {
            try loginItem.register()
        }
    }
}
