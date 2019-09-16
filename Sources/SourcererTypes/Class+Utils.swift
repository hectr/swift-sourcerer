import Foundation
import SourceryRuntime

extension Class {
    public var isTestCase: Bool {
        let suffixes = ["Specs", "Spec", "Tests", "Test", "TestCases", "TestCase", "Should"]
        let prefixes = ["ST_"]
        for inheritedType in inheritedTypes + [name] {
            for suffix in suffixes {
                if inheritedType.hasSuffix(suffix) {
                    return true
                }
            }
            for prefix in prefixes {
                if inheritedType.hasPrefix(prefix) {
                    return true
                }
            }
        }
        return false
    }
    
    public var isNSObject: Bool {
        return namesOfBaseTypes.contains("NSObject")
    }
    
    public var isUIView: Bool {
        return namesOfBaseTypes.contains { $0.hasPrefix("UI") && $0.hasSuffix("View") }
    }
        
    public var isUIViewController: Bool {
        return namesOfBaseTypes.contains { $0.hasPrefix("UI") && $0.hasSuffix("Controller") }
    }
}
