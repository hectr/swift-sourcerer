import Foundation
import SourceryRuntime

extension AccessLevel {
    public var isNonAccessible: Bool {
        switch self {
        case .none: return false
        case .private, .fileprivate: return true
        case .internal, .public, .open: return false
        }
    }

    public var isAccessible: Bool {
        switch self {
        case .none: return false
        case .private, .fileprivate: return false
        case .internal, .public, .open: return true
        }
    }

    public static func isNonAccessible(rawValue: String) -> Bool {
        guard let accessLevel = AccessLevel(rawValue: rawValue) else { return false }
        return accessLevel.isNonAccessible
    }

    public static func isAccessible(rawValue: String) -> Bool {
        guard let accessLevel = AccessLevel(rawValue: rawValue) else { return false }
        return accessLevel.isAccessible
    }
}
