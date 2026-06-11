import MoveToScreenDomain

/// The port the use case talks to for reading and mutating windows
/// belonging to other apps. The real implementation (AXAdapter) sits in
/// MoveToScreenAdapters; in-memory fakes for tests sit in
/// MoveToScreenTestSupport.
///
/// Methods that mutate window state (move, unminimize) are `throws`;
/// read methods are also `throws` because AX queries can fail when an
/// app exits between snapshot and read.
public protocol AccessibilityClient {
    /// Apps with at least one eligible window on the current Space.
    /// The adapter pre-filters by calling `isEligible` so the menu can
    /// be drawn from this list directly.
    func runningAppsWithEligibleWindows() throws -> [AppDescription]

    /// Every window the AX API reports for the given app, eligible or not.
    /// Callers filter with `isEligible` as needed.
    func windows(for app: AppId) throws -> [WindowSnapshot]

    /// Move a window so its frame matches the given destination frame.
    /// The adapter performs the AX position + size writes in sequence.
    func move(window: WindowId, to frame: Frame) throws

    /// Restore a minimized window. The adapter writes `kAXMinimizedAttribute`
    /// = false; required before a `move` if the window was minimized.
    func unminimize(window: WindowId) throws

    /// Whether the user has granted the Accessibility permission to this
    /// process. Wrapped because tests need to stub it without calling
    /// the real AX trust check.
    func isAccessibilityGranted() -> Bool
}
