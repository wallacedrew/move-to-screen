import MoveToScreenDomain

/// The port the use case talks to for reading the user's display
/// arrangement. Connected displays are read fresh each time so that
/// hot-plugging an external monitor between menu opens is reflected.
public protocol DisplayClient {
    /// Every currently-connected display, in NSScreen order
    /// (built-in first by default, externals in arrangement order).
    func connectedDisplays() -> [DisplayInfo]
}
