import ApplicationServices
import CoreGraphics
import MoveToScreenDomain

/// The trust boundary between the AX API (CFTypeRef everything) and the
/// strongly-typed Domain layer. All AX reads and writes funnel through
/// the small set of helpers here so the rest of the AXAdapter never
/// casts a raw CFTypeRef.
///
/// The Domain layer is intentionally unaware of AX — these helpers
/// translate AX attribute reads into typed values and throw
/// `AXAdapterError` on shape mismatch.

/// Undocumented but stable since macOS 10.5 — returns the CGWindowID
/// for an AXUIElement that represents a window. Used to intersect AX
/// window enumerations with `CGWindowListCopyWindowInfo` for current-Space
/// detection. The risk of Apple removing it is real but small; documented
/// in the spec under "Distribution" + private-API exposure.
@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(
    _ element: AXUIElement,
    _ windowID: UnsafeMutablePointer<CGWindowID>
) -> AXError

enum AXBoundary {

    /// Bundles the three things that always travel together when bridging
    /// an AXValue-backed attribute: the AX attribute name, the matching
    /// `AXValueType`, and a zero-initialized value to fill in on read.
    private struct AXSpec<T: Sendable>: Sendable {
        let attribute: String
        let valueType: AXValueType
        let initial: T
    }

    private static let positionSpec = AXSpec(
        attribute: kAXPositionAttribute as String,
        valueType: .cgPoint,
        initial: CGPoint.zero
    )

    private static let sizeSpec = AXSpec(
        attribute: kAXSizeAttribute as String,
        valueType: .cgSize,
        initial: CGSize.zero
    )

    static func readPosition(_ element: AXUIElement) throws -> CGPoint {
        return try readAXValue(element, spec: positionSpec)
    }

    static func readSize(_ element: AXUIElement) throws -> CGSize {
        return try readAXValue(element, spec: sizeSpec)
    }

    static func readBool(_ element: AXUIElement, _ attribute: String) -> Bool {
        guard let raw = try? readAttribute(element, attribute) else { return false }
        return (raw as? Bool) ?? false
    }

    static func readWindowId(_ element: AXUIElement) throws -> WindowId {
        var windowID: CGWindowID = 0
        let result = _AXUIElementGetWindow(element, &windowID)
        guard result == .success else {
            throw AXAdapterError.readFailed(attribute: "_AXUIElementGetWindow", result)
        }
        return WindowId(rawValue: windowID)
    }

    static func readWindows(_ application: AXUIElement) throws -> [AXUIElement] {
        let raw = try readAttribute(application, kAXWindowsAttribute as String)
        guard let array = raw as? [AXUIElement] else {
            throw AXAdapterError.unexpectedShape(attribute: kAXWindowsAttribute as String)
        }
        return array
    }

    static func writePosition(_ element: AXUIElement, _ point: CGPoint) throws {
        try writeAXValue(element, spec: positionSpec, value: point)
    }

    static func writeSize(_ element: AXUIElement, _ size: CGSize) throws {
        try writeAXValue(element, spec: sizeSpec, value: size)
    }

    static func writeMinimized(_ element: AXUIElement, _ minimized: Bool) throws {
        let result = AXUIElementSetAttributeValue(
            element, kAXMinimizedAttribute as CFString, minimized as CFTypeRef
        )
        guard result == .success else {
            throw AXAdapterError.writeFailed(attribute: kAXMinimizedAttribute as String, result)
        }
    }

    // MARK: - Private

    private static func readAttribute(_ element: AXUIElement, _ attribute: String) throws -> CFTypeRef {
        var raw: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            element, attribute as CFString, &raw
        )
        guard result == .success, let value = raw else {
            throw AXAdapterError.readFailed(attribute: attribute, result)
        }
        return value
    }

    private static func writeAXValue<T>(
        _ element: AXUIElement,
        spec: AXSpec<T>,
        value: T
    ) throws {
        var mutable = value
        guard let axValue = AXValueCreate(spec.valueType, &mutable) else {
            throw AXAdapterError.unexpectedShape(attribute: spec.attribute)
        }
        let result = AXUIElementSetAttributeValue(element, spec.attribute as CFString, axValue)
        guard result == .success else {
            throw AXAdapterError.writeFailed(attribute: spec.attribute, result)
        }
    }

    private static func readAXValue<T>(
        _ element: AXUIElement,
        spec: AXSpec<T>
    ) throws -> T {
        let raw = try readAttribute(element, spec.attribute)
        guard CFGetTypeID(raw) == AXValueGetTypeID() else {
            throw AXAdapterError.unexpectedShape(attribute: spec.attribute)
        }
        let axValue = raw as! AXValue
        var value = spec.initial
        guard AXValueGetValue(axValue, spec.valueType, &value) else {
            throw AXAdapterError.unexpectedShape(attribute: spec.attribute)
        }
        return value
    }
}
