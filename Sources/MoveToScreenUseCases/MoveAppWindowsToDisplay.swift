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
        var skipped: [SkipReason] = []

        for window in windows {
            switch outcome(for: window, destination: destinationDisplay, displays: allDisplays) {
            case .moved:
                moved += 1
            case .skipped(let reason):
                skipped.append(reason)
            }
        }

        return MoveResult(moved: moved, skipped: skipped)
    }

    private enum WindowOutcome {
        case moved
        case skipped(SkipReason)
    }

    private func outcome(
        for window: WindowSnapshot,
        destination: DisplayInfo,
        displays: [DisplayInfo]
    ) -> WindowOutcome {
        if let reason = ineligibilityReason(for: window) {
            return .skipped(reason)
        }
        guard let sourceDisplay = displayContaining(frame: window.frame, in: displays) else {
            return .skipped(.sourceDisplayNotFound(window.id))
        }
        let destinationFrame = relativePosition(
            window: window.frame,
            sourceDisplay: sourceDisplay.frame,
            destinationDisplay: destination.frame
        )
        if window.isMinimized {
            do {
                try accessibility.unminimize(window: window.id)
            } catch {
                return .skipped(.unminimizeFailed(window.id, message: "\(error)"))
            }
        }
        do {
            try accessibility.move(window: window.id, to: destinationFrame)
            return .moved
        } catch {
            return .skipped(.moveFailed(window.id, message: "\(error)"))
        }
    }

}
