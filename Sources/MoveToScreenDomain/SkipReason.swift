/// Why a window was not moved. Each case names the window for the
/// view layer's error reporting.
public enum SkipReason: Hashable, Sendable {
    case fullscreen(WindowId)
    case onAnotherSpace(WindowId)
    case sourceDisplayNotFound(WindowId)
    case moveFailed(WindowId, message: String)
    case unminimizeFailed(WindowId, message: String)
}
