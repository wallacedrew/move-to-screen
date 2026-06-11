import AppKit
import MoveToScreenDomain
import MoveToScreenPorts

/// Real `DisplayClient`, backed by `NSScreen`. Maps NSScreen's flipped
/// (origin bottom-left, Y-up) coordinate system into the Accessibility
/// API's coordinate system (origin top-left of the primary display,
/// Y-down) — once, at this boundary, so the rest of the codebase only
/// has to think in one convention.
public final class NSScreenAdapter: DisplayClient {

    public init() {}

    public func connectedDisplays() -> [DisplayInfo] {
        let screens = NSScreen.screens
        guard let primary = screens.first else { return [] }
        let primaryHeight = Double(primary.frame.height)

        return screens.map { screen in
            DisplayInfo(
                id: screen.displayId,
                name: screen.localizedName,
                frame: axFrame(from: screen.frame, primaryHeight: primaryHeight)
            )
        }
    }

    private func axFrame(from nsFrame: NSRect, primaryHeight: Double) -> Frame {
        return Frame(
            x: Double(nsFrame.origin.x),
            y: primaryHeight - Double(nsFrame.origin.y + nsFrame.height),
            width: Double(nsFrame.width),
            height: Double(nsFrame.height)
        )
    }
}

extension NSScreen {
    /// `CGDirectDisplayID` for this screen, exposed via the documented
    /// `deviceDescription[NSScreenNumber]` accessor — no private APIs.
    fileprivate var displayId: DisplayId {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        let raw = (deviceDescription[key] as? NSNumber)?.uint32Value ?? 0
        return DisplayId(rawValue: raw)
    }
}
