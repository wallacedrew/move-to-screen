/// The explanatory inverse of `isEligible`. Returns the `SkipReason`
/// that disqualifies a window from being bulk-moved, or `nil` when the
/// window is eligible. Lives in Domain so the use case and any other
/// caller share one canonical answer to "why was this window skipped?"
public func ineligibilityReason(for window: WindowSnapshot) -> SkipReason? {
    if window.isFullscreen {
        return .fullscreen(window.id)
    }
    if !window.isOnCurrentSpace {
        return .onAnotherSpace(window.id)
    }
    return nil
}
