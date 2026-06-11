/// The port the menu talks to for the "open MoveToScreen at login"
/// toggle. The real adapter wraps `SMAppService.mainApp`; tests stand
/// in an in-memory fake that records register/unregister calls.
public protocol LoginItemClient {
    /// Whether the app is currently registered to launch at login.
    func isEnabled() -> Bool

    /// Register the app as a Login Item. Idempotent — calling when
    /// already registered is a no-op for the user.
    func register() throws

    /// Unregister the app so it no longer launches at login.
    /// Idempotent — calling when not registered is a no-op for the user.
    func unregister() throws
}
