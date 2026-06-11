/// The pure compute phase of moving a window: decide whether the
/// window can be placed on the destination display and, if so, at what
/// frame. The use case's impure phase (unminimize + move via
/// AccessibilityClient) acts on this plan.
public enum PlacementPlan: Hashable, Sendable {
    case place(at: Frame)
    case skip(SkipReason)
}

/// Decides what to do with one window given the destination display and
/// the full set of connected displays. Pure — no AccessibilityClient,
/// no side effects, fully testable as microtests.
public func placementPlan(
    for window: WindowSnapshot,
    in displays: [DisplayInfo],
    destination: DisplayInfo
) -> PlacementPlan {
    if let reason = ineligibilityReason(for: window) {
        return .skip(reason)
    }
    guard let sourceDisplay = displayContaining(frame: window.frame, in: displays) else {
        return .skip(.sourceDisplayNotFound(window.id))
    }
    let destinationFrame = relativePosition(
        window: window.frame,
        sourceDisplay: sourceDisplay.frame,
        destinationDisplay: destination.frame
    )
    return .place(at: destinationFrame)
}
