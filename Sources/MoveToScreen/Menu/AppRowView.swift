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

    init(
        app: AppDescription,
        isChecked: Bool,
        target: AnyObject,
        action: Selector
    ) {
        super.init(frame: NSRect(x: 0, y: 0, width: 240, height: AppRowView.rowHeight))

        let checkbox = NSButton(checkboxWithTitle: "", target: target, action: action)
        checkbox.state = isChecked ? .on : .off
        checkbox.tag = Int(app.id.rawValue)
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: app.displayName)
        label.font = NSFont.menuFont(ofSize: 0)
        label.translatesAutoresizingMaskIntoConstraints = false

        let chevron = NSImageView(
            image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
                ?? NSImage()
        )
        chevron.contentTintColor = .secondaryLabelColor
        chevron.translatesAutoresizingMaskIntoConstraints = false

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
}
