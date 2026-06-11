import AppKit
import SwiftUI
import MoveToScreenDomain

extension NSScreen {

    /// The bottom-left origin that places a rect of `size` centered on this screen.
    fileprivate func centerOrigin(for size: NSSize) -> NSPoint {
        NSPoint(
            x: frame.origin.x + (frame.width - size.width) / 2,
            y: frame.origin.y + (frame.height - size.height) / 2
        )
    }
}

/// Owns one borderless floating NSPanel per display. Show/hide on demand
/// when the user hovers a display-name row in the submenu, so the user
/// can map a cryptic LG-model-number name like "H24T27 (1)" to the
/// physical screen before clicking.
///
/// Uses NSScreen for positioning (NS coords) — bypasses the AX-coords
/// stored on DisplayInfo to keep the NSWindow placement code simple.
@MainActor
final class DisplayBadgePresenter {

    private var panelsByDisplay: [DisplayId: NSPanel] = [:]

    func show(_ display: DisplayInfo) {
        guard let screen = nsScreen(for: display.id) else { return }
        let panel = panelsByDisplay[display.id] ?? makePanel(for: display, on: screen)
        panelsByDisplay[display.id] = panel
        panel.setFrameOrigin(screen.centerOrigin(for: panel.frame.size))
        panel.orderFront(nil)
    }

    func hideAll() {
        for panel in panelsByDisplay.values {
            panel.orderOut(nil)
        }
    }

    // MARK: - Private

    private func makePanel(for display: DisplayInfo, on screen: NSScreen) -> NSPanel {
        let maxWidth = screen.frame.width * 0.6
        let host = NSHostingView(
            rootView: DisplayBadgeView(displayName: display.name, maxWidth: maxWidth)
        )
        host.frame = NSRect(origin: .zero, size: host.intrinsicContentSize)

        let panel = NSPanel(
            contentRect: host.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = host
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        return panel
    }

    private func nsScreen(for displayId: DisplayId) -> NSScreen? {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        return NSScreen.screens.first { screen in
            (screen.deviceDescription[key] as? NSNumber)?.uint32Value == displayId.rawValue
        }
    }
}
