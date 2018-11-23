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
        writer.writeTitle("Untested public types")
        writer.writeTitle("Classes", level: 1)
        writer.lines += [""]
        writer.lines += untestedPublicClasses.map { "- \($0)" }
        writer.writeTitle("Structs", level: 1)
        writer.lines += [""]
        writer.lines += untestedPublicStructs.map { "- \($0)" }
        writer.writeTitle("Untested internal types")
        writer.writeTitle("Classes", level: 1)
        writer.lines += [""]
        writer.lines += untestedInternalClasses.map { "- \($0)" }
        writer.writeTitle("Structs", level: 1)
        writer.lines += [""]
        writer.lines += untestedInternalStructs.map { "- \($0)" }
    }

    private var untestedPublicClasses: [String] {
        let publicClasses = classes
            .filter { $0.hasPublicAccess && $0.hasPublicAccessMethods }
        return untestedTypes(types: publicClasses)
    }

    private var untestedPublicStructs: [String] {
        let publicClasses = structs
            .filter { $0.hasPublicAccess && $0.hasPublicAccessMethods }
        return untestedTypes(types: publicClasses)
    }

    private var untestedInternalClasses: [String] {
        let publicClasses = classes
            .filter { $0.hasInternalAccess && ($0.hasInternalAccessMethods || $0.hasPublicAccessMethods) }
        return untestedTypes(types: publicClasses)
    }

    private var untestedInternalStructs: [String] {
        let publicClasses = structs
            .filter { $0.hasInternalAccess && ($0.hasInternalAccessMethods || $0.hasPublicAccessMethods) }
        return untestedTypes(types: publicClasses)
    }

    private func untestedTypes(types: [Type]) -> [String] {
        let typeNames = types
            .map { $0.name.replacingOccurrences(of: ".", with: "") }
            .sorted { $0.count > $1.count }
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

    var hasInternalAccess: Bool {
        guard let accessLevel = AccessLevel(rawValue: self.accessLevel) else { return false }
        switch accessLevel {
        case .none, .internal: return true
        case .public, .open: return false
        case .fileprivate, .private: return false
        }
    }

    var hasInternalAccessMethods: Bool {
        let methods = self.methods.filter { !$0.isInitializer }
        for method in methods {
            guard let accessLevel = AccessLevel(rawValue: method.accessLevel) else { return false }
            switch accessLevel {
            case .none, .internal: return true
            case .public, .open: continue
            case .fileprivate, .private: continue
            }
        }
        return false
    }
}
