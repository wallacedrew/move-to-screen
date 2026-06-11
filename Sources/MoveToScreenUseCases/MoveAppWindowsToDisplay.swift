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

    public func move(app: AppId, to destination: DisplayId) throws -> MoveResult {
        let allDisplays = displayClient.connectedDisplays()
        guard let destinationDisplay = allDisplays.first(where: { $0.id == destination }) else {
            return MoveResult(moved: 0, skipped: [])
        }

        let outcomes = try accessibility.windows(for: app).map {
            outcome(for: $0, destination: destinationDisplay, among: allDisplays)
        }
        return MoveResult(
            moved: outcomes.count(where: \.isMoved),
            skipped: outcomes.compactMap(\.skipReason)
        )
    }

    private enum WindowOutcome {
        case moved
        case skipped(SkipReason)

        var isMoved: Bool {
            if case .moved = self { true } else { false }
        }

        var skipReason: SkipReason? {
            if case .skipped(let reason) = self { return reason }
            return nil
        }
    }

    private func outcome(
        for window: WindowSnapshot,
        destination: DisplayInfo,
        among displays: [DisplayInfo]
    ) -> WindowOutcome {
        switch placementPlan(for: window, in: displays, destination: destination) {
        case .skip(let reason):
            return .skipped(reason)
        case .place(let frame):
            return apply(frame, to: window)
        }
    }

    private func apply(_ frame: Frame, to window: WindowSnapshot) -> WindowOutcome {
        if window.isMinimized {
            do {
                try accessibility.unminimize(window: window.id)
            } catch {
                return .skipped(.unminimizeFailed(window.id, message: "\(error)"))
            }
        }
        do {
            try accessibility.move(window: window.id, to: frame)
            return .moved
        } catch {
            return .skipped(.moveFailed(window.id, message: "\(error)"))
        }
    }

}
