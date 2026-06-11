/// Identity of a connected display.
/// Wraps `CGDirectDisplayID`; modeled as `UInt32` so the Domain layer
/// stays free of CoreGraphics imports.
public struct DisplayId: Hashable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}
