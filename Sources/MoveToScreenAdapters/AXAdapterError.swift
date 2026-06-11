import ApplicationServices

/// Errors raised by the AXAdapter when an AX call returns non-success or
/// when a CFTypeRef value has an unexpected shape. The `attribute` field
/// is the AX attribute name (`kAXPositionAttribute` etc.) so diagnostics
/// point at the exact attribute that failed.
public enum AXAdapterError: Error, CustomStringConvertible {
    case readFailed(attribute: String, AXError)
    case writeFailed(attribute: String, AXError)
    case unexpectedShape(attribute: String)

    public var description: String {
        switch self {
        case .readFailed(let attr, let err):
            return "AX read failed for \(attr): \(err)"
        case .writeFailed(let attr, let err):
            return "AX write failed for \(attr): \(err)"
        case .unexpectedShape(let attr):
            return "AX returned unexpected shape for \(attr)"
        }
    }
}
