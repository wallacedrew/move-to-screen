import MoveToScreenDomain
import MoveToScreenPorts

/// Orchestrator for "move every eligible window of these apps onto one
/// display". Caller supplies the list — the "move all" case is callers
/// passing in every running app; the "move selected" case is callers
/// passing in a user-chosen subset. Delegates each app to
/// MoveAppWindowsToDisplay and aggregates the per-app MoveResults.
public final class MoveAppsWindowsToDisplay {

    private let perApp: MoveAppWindowsToDisplay

    public init(accessibility: AccessibilityClient, displayClient: DisplayClient) {
        self.perApp = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
    }

    public func move(apps: [AppId], to destination: DisplayId) throws -> MoveResult {
        let perAppResults = try apps.map { try perApp.move(app: $0, to: destination) }
        return MoveResult(
            moved: perAppResults.map(\.moved).reduce(0, +),
            skipped: perAppResults.flatMap(\.skipped)
        )
    }
}
