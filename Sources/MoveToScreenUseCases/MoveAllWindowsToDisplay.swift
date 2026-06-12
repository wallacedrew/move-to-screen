import MoveToScreenDomain
import MoveToScreenPorts

/// Orchestrator for the "move every running app's eligible windows
/// onto one display" user journey. Enumerates apps via the
/// AccessibilityClient and delegates each one to MoveAppWindowsToDisplay,
/// aggregating the per-app MoveResults into a single result.
public final class MoveAllWindowsToDisplay {

    private let accessibility: AccessibilityClient
    private let perApp: MoveAppWindowsToDisplay

    public init(accessibility: AccessibilityClient, displayClient: DisplayClient) {
        self.accessibility = accessibility
        self.perApp = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
    }

    public func move(to destination: DisplayId) throws -> MoveResult {
        let perAppResults = try accessibility
            .runningAppsWithEligibleWindows()
            .map { try perApp.move(app: $0.id, to: destination) }
        return MoveResult(
            moved: perAppResults.map(\.moved).reduce(0, +),
            skipped: perAppResults.flatMap(\.skipped)
        )
    }
}
