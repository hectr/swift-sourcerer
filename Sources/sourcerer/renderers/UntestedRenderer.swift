import Foundation
import SourceryRuntime
import SourcererTypes
import SourcererRenderer

public final class UntestedRenderer: AbstractRenderer<TypesReport> {
    public init(types: Types) {
        super.init(types: types, writer: TypesReport())
    }

    public override var filename: String {
        return "untested.md"
    }

    public override func render() {
        writer.writeTitle("Untested classes and structs")
        writer.lines += [""]
        writer.lines += untestedClassesAndStructsNames.map { "- \($0)" }
    }

    private var untestedClassesAndStructsNames: [String] {
        let publicClasses = classesAndStructs.filter { $0.hasPublicAccess && $0.hasPublicAccessMethods }
        let typeNames = publicClasses.map { $0.name.replacingOccurrences(of: ".", with: "") }
        var untestedTypes = Set(typeNames)
        var testCasesNames = Set(testCases.map { $0.localName })
        for typeName in typeNames {
            guard !testCasesNames.contains(typeName) else { continue }
            var match: String?
            for testCasesName in testCasesNames {
                if testCasesName.contains(typeName) {
                    match = testCasesName
                    break
                }
            }
            if let match = match {
                untestedTypes.remove(typeName)
                testCasesNames.remove(match)
            }
        }
        return untestedTypes.sorted()
    }
}

private extension Type {
    var hasPublicAccess: Bool {
        guard let accessLevel = AccessLevel(rawValue: self.accessLevel) else { return false }
        switch accessLevel {
        case .none, .internal, .fileprivate, .private: return false
        case .public, .open: return true
        }
    }

    var hasPublicAccessMethods: Bool {
        for method in methods {
            guard let accessLevel = AccessLevel(rawValue: method.accessLevel) else { return false }
            switch accessLevel {
            case .none, .internal, .fileprivate, .private: continue
            case .public, .open: return true
            }
        }
        return false
    }
}
