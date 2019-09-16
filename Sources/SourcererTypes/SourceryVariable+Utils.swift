import Foundation
import SourceryRuntime

extension SourceryVariable {
    public var isDelegate: Bool {
        return name == "delegate" ||
            name.hasSuffix("Delegate") ||
            typeName.name.hasSuffix("Delegate")
    }
}
