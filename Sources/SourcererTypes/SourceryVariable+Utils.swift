import Foundation
import SourceryRuntime

public extension SourceryVariable {
    var isDelegate: Bool {
        return name == "delegate" ||
            name.hasSuffix("Delegate") ||
            typeName.name.hasSuffix("Delegate")
    }
}
