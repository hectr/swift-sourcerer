import Foundation
import SourceryRuntime

public extension Class {
    var isTestCase: Bool {
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
    
    var isNSObject: Bool {
        return namesOfBaseTypes.contains("NSObject")
    }
    
    var isUIView: Bool {
        return namesOfBaseTypes.filter { $0.hasPrefix("UI") && $0.hasSuffix("View") }.count != 0
    }
        
    var isUIViewController: Bool {
        return namesOfBaseTypes.filter { $0.hasPrefix("UI") && $0.hasSuffix("Controller") }.count != 0
    }
}
