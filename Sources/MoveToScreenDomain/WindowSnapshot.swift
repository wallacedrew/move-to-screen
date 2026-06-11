/// A read-only snapshot of an app's window taken at the moment the
/// menu was opened. `isOnCurrentSpace` is determined by the adapter
/// by intersecting the AX window list with
/// `CGWindowListCopyWindowInfo(.optionOnScreenOnly, ...)`.
public struct WindowSnapshot: Hashable, Sendable {
    public let id: WindowId
    public let ownerApp: AppId
    public let frame: Frame
    public let isMinimized: Bool
    public let isFullscreen: Bool
    public let isOnCurrentSpace: Bool

    public init(
        id: WindowId,
        ownerApp: AppId,
        frame: Frame,
        isMinimized: Bool,
        isFullscreen: Bool,
        isOnCurrentSpace: Bool
    ) {
        self.id = id
        self.ownerApp = ownerApp
        self.frame = frame
        self.isMinimized = isMinimized
        self.isFullscreen = isFullscreen
        self.isOnCurrentSpace = isOnCurrentSpace
    }
}
