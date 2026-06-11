/// Maps a window's frame from a source display onto a destination display,
/// preserving the window's proportional position. Window size is kept;
/// the position is clamped to keep the window within the destination bounds.
///
/// Driven by microtests in RelativePositionTests.
public func relativePosition(
    window: Frame,
    sourceDisplay: Frame,
    destinationDisplay: Frame
) -> Frame {
    let relativeX = (window.origin.x - sourceDisplay.origin.x) / sourceDisplay.size.width
    let relativeY = (window.origin.y - sourceDisplay.origin.y) / sourceDisplay.size.height
    let proportionalX = destinationDisplay.origin.x + relativeX * destinationDisplay.size.width
    let proportionalY = destinationDisplay.origin.y + relativeY * destinationDisplay.size.height
    let finalWidth = min(window.size.width, destinationDisplay.size.width)
    let finalHeight = min(window.size.height, destinationDisplay.size.height)
    let maxX = destinationDisplay.origin.x + destinationDisplay.size.width - finalWidth
    let maxY = destinationDisplay.origin.y + destinationDisplay.size.height - finalHeight
    let clampedX = max(destinationDisplay.origin.x, min(proportionalX, maxX))
    let clampedY = max(destinationDisplay.origin.y, min(proportionalY, maxY))
    return Frame(
        x: clampedX,
        y: clampedY,
        width: finalWidth,
        height: finalHeight
    )
}
