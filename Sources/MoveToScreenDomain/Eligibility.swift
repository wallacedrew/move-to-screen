/// A window is eligible for bulk-move when it is on the user's current
/// Space and is not in fullscreen mode. Minimized windows on the current
/// Space are eligible (the use case un-minimizes them before moving).
///
/// Driven by microtests in EligibilityTests.
public func isEligible(_ window: WindowSnapshot) -> Bool {
    return !window.isFullscreen
}
