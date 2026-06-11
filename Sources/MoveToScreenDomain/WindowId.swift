/// Identity of a window owned by an app.
/// Wraps `CGWindowID` (a stable, per-window number assigned by the
/// macOS WindowServer); modeled as `UInt32` so the Domain stays
/// independent of CoreGraphics.
public struct WindowId: Hashable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}
