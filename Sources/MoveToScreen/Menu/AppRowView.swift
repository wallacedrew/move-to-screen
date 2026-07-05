import AppKit
import MoveToScreenDomain

/// Custom NSView used as the rendering surface for each per-app
/// NSMenuItem. Hosts a leading NSButton (checkbox style) whose
/// target/action toggles selection in the view model, the app name
/// label in the middle, and a trailing chevron that mimics the
/// standard submenu indicator. The NSButton consumes its own click,
/// so the menu stays open while the user ticks several apps.
@MainActor
final class AppRowView: NSView {

    private static let rowHeight: CGFloat = 22
    private static let leadingPadding: CGFloat = 16
    private static let trailingPadding: CGFloat = 10
    private static let checkboxToLabelSpacing: CGFloat = 6
    private static let labelToChevronSpacing: CGFloat = 8
    private static let highlightInset: CGFloat = 5
    private static let highlightCornerRadius: CGFloat = 4

    private let label: NSTextField
    private let chevron: NSImageView
    private var isHighlighted = false

    init(
        app: AppDescription,
        isChecked: Bool,
        target: AnyObject,
        action: Selector
    ) {
        label = NSTextField(labelWithString: app.displayName)
        label.font = NSFont.menuFont(ofSize: 0)
        label.translatesAutoresizingMaskIntoConstraints = false

        chevron = NSImageView(
            image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
                ?? NSImage()
        )
        chevron.contentTintColor = .secondaryLabelColor
        chevron.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: NSRect(x: 0, y: 0, width: 240, height: AppRowView.rowHeight))

        let checkbox = NSButton(checkboxWithTitle: "", target: target, action: action)
        checkbox.state = isChecked ? .on : .off
        checkbox.tag = Int(app.id.rawValue)
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkbox)
        addSubview(label)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppRowView.leadingPadding),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),

            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: AppRowView.checkboxToLabelSpacing),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevron.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: AppRowView.labelToChevronSpacing),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppRowView.trailingPadding),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: AppRowView.rowHeight)
    }

    // MARK: - Hover highlight

    override func updateTrackingAreas() {
        for existingArea in trackingAreas {
            removeTrackingArea(existingArea)
        }
        addTrackingArea(
            NSTrackingArea(
                rect: bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self
            )
        )
        super.updateTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        isHighlighted = true
        refreshHighlightAppearance()
    }

    override func mouseExited(with event: NSEvent) {
        isHighlighted = false
        refreshHighlightAppearance()
    }

    private func refreshHighlightAppearance() {
        label.textColor = isHighlighted ? .selectedMenuItemTextColor : .labelColor
        chevron.contentTintColor = isHighlighted ? .selectedMenuItemTextColor : .secondaryLabelColor
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard isHighlighted else { return }

        let highlightRect = bounds.insetBy(dx: AppRowView.highlightInset, dy: 0)
        let highlightPath = NSBezierPath(
            roundedRect: highlightRect,
            xRadius: AppRowView.highlightCornerRadius,
            yRadius: AppRowView.highlightCornerRadius
        )
        NSColor.selectedContentBackgroundColor.setFill()
        highlightPath.fill()
    }
}
