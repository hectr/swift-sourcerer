import Foundation
import SourceryRuntime
import SourcererTypes
import SourcererRenderer

public final class StatsRenderer: AbstractRenderer<TypesReport> {
    public init(types: Types) {
        super.init(types: types, writer: TypesReport())
    }

    public override var filename: String {
        return "stats.md"
    }

    public override func render() {
        writeTypesSummary()
        writeMethodsReport()
        writeTypesReport()
        writeDependenciesReport()
    }
    
    private func writeTypesSummary() {
        writer.writeTitle("Stats")
        writer.lines += [""]
        writer.lines += ["There are **\(all.count) types** (of which \(privateTypes.count) are private)."]
        writer.lines += [""]
        writer.lines += [" - \(testCases.count) test cases"]
        writer.lines += [" - \(classes.count) classes (of which \(finalClasses.count) are final)"]
        writer.lines += [" - \(structs.count) structs"]
        writer.lines += [" - \(enums.count) enums"]
        writer.lines += [" - \(protocols.count) protocols (of which \(delegateProtocols.count) are delegates)"]
        writer.lines += [" - \(externalExtensions.count) *external* dependencies extensions"]
    }

    private func writeMethodsReport() {
        let optionalReturnMethodsNoThrow = optionalReturnMethods.filter { !$0.throws }
        let optionalReturnMethodsThrow = optionalReturnMethods.filter { $0.throws }
        writer.writeTitle("Methods", level: 1)
        writer.writeLine()
        writer.writeLine("There are **\(optionalReturnMethodsNoThrow.count) methods that return an optional** value instead of throwing.")
        writer.writeAsList(optionalReturnMethodsNoThrow.map { "\($0.definedInType != nil ? $0.definedInType!.name + "." : "")\($0.selectorName) -> \($0.returnTypeName.name)" })
        writer.writeLine()
        writer.writeLine("There are **\(optionalReturnMethodsThrow.count) methods that can throw and return an optional** value.")
        writer.writeAsList(optionalReturnMethodsThrow.map { "\($0.definedInType != nil ? $0.definedInType!.name + "." : "")\($0.selectorName) throws -> \($0.returnTypeName.name)" })
    }

    private func writeTypesReport() {
        // instances
        writer.writeTitle("Instances", level: 1)
        writer.write(types: singletons,
                     label: "singleton",
                     subset: objcSingletons,
                     subsetLabel: "NSObject types")
        writer.write(types: staticInstance,
                     label: "static instance",
                     subset: objcStaticInstance,
                     subsetLabel: "NSObject types")
        writer.write(types: staticTypes,
                     label: "static",
                     subset: instantiableStaticTypes,
                     subsetLabel: "instantiable")
        // data
        writer.writeTitle("Data", level: 1)
        writer.write(types: mutable,
                     label: "mutable",
                     disclosePrivate: true)
        writer.write(types: stateLess,
                     label: "state-less")
        writer.write(types: dataTypes,
                     label: "data-only")
        // nested
        writer.write(title: "Nesting",
                     types: nested,
                     label: "nested",
                     disclosePrivate: true,
                     sortCriteria: {
                        $0.nestingLevel*(AccessLevel.isNonAccessible(rawValue: $0.accessLevel) ? 1 : 3)
                     })
        // generics
        writer.write(title: "Generics",
                     types: generics,
                     label: "generic")
        // NSObject
        writer.writeTitle("Objective-C", level: 1)
        writer.write(title: "NSObject",
                     titleLevel: 2,
                     types: nsobjects,
                     label: "NSObject")
        writer.write(title: "UIView",
                     titleLevel: 2,
                     types: views,
                     label: "view subclass")
        writer.write(title: "UIViewController",
                     titleLevel: 2,
                     types: viewControllers,
                     label: "view controller subclass")
    }

    private func writeDependenciesReport() {
        var instabilities = [Type: Double]()
        for (type, outgoing) in knownDependencies {
            guard let incoming = incomingDependencies[type] else { continue }
            let totalCoupling = outgoing.count + incoming.count
            guard totalCoupling > 0 else { continue }
            let instability = Double(outgoing.count)/Double(totalCoupling)
            instabilities[type] = instability
        }
        var instableDependencies = [TypesReport.TypeCounter]()
        for (type, outgoing) in knownDependencies {
            guard type is Class || type is Struct else { continue }
            guard let typeInstability = instabilities[type] else { continue }
            let dependenciesInstabilities = outgoing.compactMap { instabilities[$0] }
            let count = dependenciesInstabilities.reduce(0) { typeInstability > $1 ? $0 : $0 + 1 }
            instableDependencies.append(TypesReport.TypeCounter(type: type, count: count))
        }
        writer.writeTitle("Declared dependencies", level: 1)
        writer.writeLine()
        writer.writeLine("There are **\(instableDependencies.count) classes and structs** that depend on less stable types than themselves.")
        writer.writeAsList(instableDependencies)
    }
}
