import Foundation
import SourceryRuntime

extension SourceryProtocol {
    public var isDelegate: Bool {
        let suffixes = ["Delegate"]
        for inheritedType in inheritedTypes + [name] {
            for suffix in suffixes {
                if inheritedType.hasSuffix(suffix) {
                    return true
                }
            }
        }
        return false
    }
}
