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

    static func readPosition(_ element: AXUIElement) throws -> CGPoint {
        return try readAXValue(
            element,
            attribute: kAXPositionAttribute as String,
            as: .cgPoint,
            initial: .zero
        )
    }

    static func readSize(_ element: AXUIElement) throws -> CGSize {
        return try readAXValue(
            element,
            attribute: kAXSizeAttribute as String,
            as: .cgSize,
            initial: .zero
        )
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
        var mutable = point
        guard let value = AXValueCreate(.cgPoint, &mutable) else {
            throw AXAdapterError.unexpectedShape(attribute: kAXPositionAttribute as String)
        }
        let result = AXUIElementSetAttributeValue(
            element, kAXPositionAttribute as CFString, value
        )
        guard result == .success else {
            throw AXAdapterError.writeFailed(attribute: kAXPositionAttribute as String, result)
        }
    }

    static func writeSize(_ element: AXUIElement, _ size: CGSize) throws {
        var mutable = size
        guard let value = AXValueCreate(.cgSize, &mutable) else {
            throw AXAdapterError.unexpectedShape(attribute: kAXSizeAttribute as String)
        }
        let result = AXUIElementSetAttributeValue(
            element, kAXSizeAttribute as CFString, value
        )
        guard result == .success else {
            throw AXAdapterError.writeFailed(attribute: kAXSizeAttribute as String, result)
        }
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

    private static func readAXValue<T>(
        _ element: AXUIElement,
        attribute: String,
        as type: AXValueType,
        initial: T
    ) throws -> T {
        let raw = try readAttribute(element, attribute)
        guard CFGetTypeID(raw) == AXValueGetTypeID() else {
            throw AXAdapterError.unexpectedShape(attribute: attribute)
        }
        let axValue = raw as! AXValue
        var value = initial
        guard AXValueGetValue(axValue, type, &value) else {
            throw AXAdapterError.unexpectedShape(attribute: attribute)
        }
        return value
    }
}
