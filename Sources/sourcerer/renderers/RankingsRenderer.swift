import Foundation
import SourceryRuntime
import SourcererTypes
import SourcererRenderer

public final class RankingsRenderer: AbstractRenderer<TypesReport> {
    private typealias TypeCounter = TypesReport.TypeCounter

    public init(types: Types) {
        super.init(types: types, writer: TypesReport())
    }

    public override var filename: String {
        return "rankings.md"
    }

    public override func render() {
        writer.writeTitle("Rankings")
        writeTypesRankings()
        writeMethodsRankings()
        writeVariablesRankings()
        writeDependenciesRankings()
    }
    
    private func writeTypesRankings() {
        writer.writeTitle("Types", level: 1)
        var inheritance = TypeCounter()
        var siblings = [Type: Set<Type>]()
        for type in classes {
            let level = type.inheritanceLevel
            if level > inheritance.count {
                inheritance.count = level
                inheritance.type = type
            }
            if let supertype = type.supertype {
                var types = siblings[supertype] ?? Set<Type>()
                types.insert(type)
                siblings[supertype] = types
            }
        }
        // inheritance degree
        writer.writeCounter(inheritance, label: "- Maximum number of inheritance degrees")
        // subclasses count
        if let superclassWithMostSubclasses = siblings.sorted(by: { $0.value.count > $1.value.count }).first {
            writer.writeLine()
            writer.lines += ["- Maximum number of subclasses:\n`\(superclassWithMostSubclasses.key.name)` (\(superclassWithMostSubclasses.value.count))"]
        }
        // nested types
        if let parentWithMostTypes = all.sorted(by: { $0.containedTypes.count > $1.containedTypes.count }).first {
            writer.writeLine()
            writer.lines += ["- Maximum number of nested types:\n`\(parentWithMostTypes.name)` (\(parentWithMostTypes.containedTypes.count))"]
        }
        // nested types
        if let typeWithLongestName = all.sorted(by: { $0.localName.count > $1.localName.count }).first {
            writer.writeLine()
            writer.lines += ["- Longest name:\n`\(typeWithLongestName.name)` (\(typeWithLongestName.localName.count))"]
        }
        // enums
        writer.writeTitle("Enums", level: 2)
        if let enumWithMostCases = self.enums.map({ TypeCounter(type: $0, counting: $0.cases) }).sorted(by:{ $0.count > $1.count }).first {
            writer.writeCounter(enumWithMostCases, label: "- Maximum number of cases in enum")
        }
        if let enumWithCaseWithMostAssociated = self.enums.map({ TypeCounter(type: $0, count: $0.cases.reduce(Int.min) { $1.associatedValues.count > $0 ? $1.associatedValues.count : $0 }) }).sorted(by:{ $0.count > $1.count }).first {
            writer.writeCounter(enumWithCaseWithMostAssociated, label: "- Maximum number of associated values in a case")
        }
    }
    
    private func writeMethodsRankings() {
        writer.writeTitle("Defined methods", level: 1)
        var instanceMethod = TypeCounter()
        var nonPrivateInstanceMethod = TypeCounter()
        var nonInstanceMethod = TypeCounter()
        var nonPrivateNonInstanceMethod = TypeCounter()
        for type in classesAndStructs {
            let instanceMethods = type.instanceMethods
            if instanceMethods.count > instanceMethod.count {
                instanceMethod.type = type
                instanceMethod.count = instanceMethods.count
            }
            let nonPrivateInstanceMethods = instanceMethods.filter { AccessLevel.isAccessible(rawValue: $0.accessLevel) }
            if nonPrivateInstanceMethods.count > nonPrivateInstanceMethod.count {
                nonPrivateInstanceMethod.type = type
                nonPrivateInstanceMethod.count = nonPrivateInstanceMethods.count
            }
            let nonInstanceMethods = type.nonInstanceMethods
            if nonInstanceMethods.count > nonInstanceMethod.count {
                nonInstanceMethod.type = type
                nonInstanceMethod.count = nonInstanceMethods.count
            }
            let nonPrivateNonInstanceMethods = nonInstanceMethods.filter { AccessLevel.isAccessible(rawValue: $0.accessLevel) }
            if nonPrivateNonInstanceMethods.count > nonPrivateNonInstanceMethod.count {
                nonPrivateNonInstanceMethod.type = type
                nonPrivateNonInstanceMethod.count = nonPrivateNonInstanceMethods.count
            }
        }
        writer.writeCounter(nonPrivateInstanceMethod, label: "- Maximum number of non-private instance methods")
        writer.writeCounter(instanceMethod, label: "- Maximum number of total instance methods")
        writer.writeCounter(nonPrivateNonInstanceMethod, label: "- Maximum number of non-private *non-instance* methods")
        writer.writeCounter(nonInstanceMethod, label: "- Maximum number of total *non-instance* methods")
    }
    
    private func writeVariablesRankings() {
        writer.writeTitle("Defined variables", level: 1)
        var instanceVariable = TypeCounter()
        var nonPrivateInstanceVariable = TypeCounter()
        var staticVariable = TypeCounter()
        var nonPrivateStaticVariable = TypeCounter()
        for type in classesAndStructs {
            let instanceVariables = type.instanceVariables
            if instanceVariables.count > instanceVariable.count {
                instanceVariable.type = type
                instanceVariable.count = instanceVariables.count
            }
            let nonPrivateInstanceVariables = instanceVariables.filter { AccessLevel.isAccessible(rawValue: $0.readAccess) }
            if nonPrivateInstanceVariables.count > nonPrivateInstanceVariable.count {
                nonPrivateInstanceVariable.type = type
                nonPrivateInstanceVariable.count = nonPrivateInstanceVariables.count
            }
            let staticVariables = type.staticVariables
            if staticVariables.count > staticVariable.count {
                staticVariable.type = type
                staticVariable.count = staticVariables.count
            }
            let nonPrivateStaticVariables = staticVariables.filter { AccessLevel.isAccessible(rawValue: $0.readAccess) }
            if nonPrivateStaticVariables.count > nonPrivateStaticVariable.count {
                nonPrivateStaticVariable.type = type
                nonPrivateStaticVariable.count = nonPrivateStaticVariables.count
            }
        }
        // instance variables
        writer.writeCounter(nonPrivateInstanceVariable, label: "- Maximum number of non-private instance variables")
        writer.writeCounter(instanceVariable, label: "- Maximum number of total instance variables")
        // static variables
        writer.writeCounter(nonPrivateStaticVariable, label: "- Maximum number of non-private static variables")
        writer.writeCounter(staticVariable, label: "- Maximum number of total static variables")
    }
    
    private func writeDependenciesRankings() {
        writer.writeTitle("Declared dependencies", level: 1)
        writer.writeTitle("Efferent coupling", level: 2)
        if let efferent = allDependencies.map({ TypeCounter(type: $0.key, counting: Array($0.value)) }).sorted(by: { $0.count > $1.count }).first {
            writer.writeCounter(efferent, label: "- Maximum number of outgoing dependencies")
        }
        if let unknown = unknownDependencies.map({ TypeCounter(type: $0.key, counting: Array($0.value)) }).sorted(by: { $0.count > $1.count }).first {
            writer.writeCounter(unknown, label: "- Maximum number of *external* outgoing dependencies")
        }
        if let known = knownDependencies.map({ TypeCounter(type: $0.key, counting: Array($0.value)) }).sorted(by: { $0.count > $1.count }).first {
            writer.writeCounter(known, label: "- Maximum number of *internal* outgoing dependencies")
        }
        writer.writeTitle("Afferent coupling", level: 2)
        if let afferent = incomingDependencies.map({ TypeCounter(type: $0.key, counting: Array($0.value)) }).sorted(by: { $0.count > $1.count }).first {
            writer.writeCounter(afferent, label: "- Maximum number of incoming dependencies")
            
        }
    }
}
