import MoveToScreenDomain
import MoveToScreenPorts

/// Orchestrator for the "consolidate all of app X's windows on display Y"
/// user journey. Reads a snapshot of the app's windows from the
/// AccessibilityClient, computes a proportional destination frame for
/// each via pure domain helpers, then issues the moves through the same
/// client. Returns a MoveResult describing what happened.
public final class MoveAppWindowsToDisplay {

    private let accessibility: AccessibilityClient
    private let displayClient: DisplayClient

    public init(accessibility: AccessibilityClient, displayClient: DisplayClient) {
        self.accessibility = accessibility
        self.displayClient = displayClient
    }

    public func execute(app: AppId, destination: DisplayId) throws -> MoveResult {
        let allDisplays = displayClient.connectedDisplays()
        guard let destinationDisplay = allDisplays.first(where: { $0.id == destination }) else {
            return MoveResult(moved: 0, skipped: [])
        }

        let windows = try accessibility.windows(for: app)
        var moved = 0

        for window in windows {
            guard let sourceDisplay = displayContaining(frame: window.frame, in: allDisplays) else {
                continue
            }
            let destinationFrame = relativePosition(
                window: window.frame,
                sourceDisplay: sourceDisplay.frame,
                destinationDisplay: destinationDisplay.frame
            )
            try accessibility.move(window: window.id, to: destinationFrame)
            moved += 1
        }

        return MoveResult(moved: moved, skipped: [])
    }
}
