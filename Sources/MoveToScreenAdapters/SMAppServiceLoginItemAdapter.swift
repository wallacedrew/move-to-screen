import ServiceManagement
import MoveToScreenPorts

/// Real `LoginItemClient` backed by `SMAppService.mainApp` (macOS 13+).
/// The system reads the bundle identifier from `Info.plist` and tracks
/// the login-item state per-user.
///
/// Caveat for unsigned builds: macOS may surface a Login Items approval
/// dialog on first `register()`. The call still returns immediately;
/// the user toggles the approval in System Settings → General → Login
/// Items. Reading `status` after a `requiresApproval` round-trip will
/// reflect the user's choice.
public final class SMAppServiceLoginItemAdapter: LoginItemClient {

    private let service: SMAppService

    public init(service: SMAppService = .mainApp) {
        self.service = service
    }

    public func isEnabled() -> Bool {
        return service.status == .enabled
    }

    public func register() throws {
        try service.register()
    }

    public func unregister() throws {
        try service.unregister()
    }
}
