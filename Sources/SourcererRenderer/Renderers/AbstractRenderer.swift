import Foundation
import SourceryRuntime
import SourcererTypes

open class AbstractRenderer<W: Writer> {
    open var filename: String {
        return String(describing: type(of: self)).appending(".swift")
    }

    // swiftlint:disable:next unavailable_function
    open func render() {
        fatalError("Subclasses must override \(#function)")
    }

    // MARK: - Initialization

    public let types: Types
    public let writer: W

    public init(types: Types, writer: W) {
        self.types = types
        self.writer = writer
    }

    // MARK: - Writer

    public func write<T: TextOutputStream>(to stream: inout T) {
        writer.reset()
        render()
        writer.write(to: &stream)
    }

    public func write(url: URL) throws {
        writer.reset()
        render()
        var isDirectory: ObjCBool = false
        let path = url.absoluteString.replacingOccurrences(of: "file://", with: "")
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue {
            try writer.write(url: url.appendingPathComponent(filename, isDirectory: false))
        } else {
            try writer.write(url: url)
        }
    }

    // MARK: - Types
    
    open lazy var all: [Type] = {
        return types.all + types.protocols
    }()
    
    open lazy var privateTypes: [Type] = {
        return all.filter { AccessLevel.isNonAccessible(rawValue: $0.accessLevel) }
    }()
    
    open lazy var testCases: [Class] = {
        return types.classes.filter { $0.isTestCase }
    }()
    
    open lazy var classes: [Class] = {
        return types.classes.filter { !$0.isTestCase && !$0.isExtension }
    }()
    open lazy var finalClasses: [Class] = {
        return classes.filter { $0.isFinal }
    }()
    
    open lazy var structs: [Struct] = {
        return types.structs.filter { !$0.isExtension }
    }()
    
    open lazy var classesAndStructs: [Type] = {
        return (classes as [Type]) + (structs as [Type])
    }()
    
    open lazy var enums: [Enum] = {
        return types.enums.filter { !$0.isExtension }
    }()
    
    open lazy var protocols: [SourceryProtocol] = {
        return types.protocols.filter { !$0.isExtension }
    }()
    open lazy var delegateProtocols: [SourceryProtocol] = {
        return protocols.filter { $0.isDelegate }
    }()
    
    open lazy var externalExtensions: [Type] = {
        return all.filter { $0.isExtension }
    }()
    
    open lazy var singletons: [Type] = {
        return classesAndStructs.filter { $0.isSingleton }
    }()
    open lazy var objcSingletons: [Type] = {
        return singletons.compactMap { $0 as? Class }.filter { $0.isNSObject }
    }()
    open lazy var staticInstance: [Type] = {
        return classesAndStructs.filter { !$0.isSingleton && $0.staticInstances == 1 }
    }()
    open lazy var objcStaticInstance: [Type] = {
        return staticInstance.compactMap { $0 as? Class }.filter { $0.isNSObject }
    }()
    
    open lazy var nested: [Type] = {
        return all.filter { $0.isNested }
    }()
    
    open lazy var generics: [Type] = {
        return all.filter { $0.isGeneric }
    }()
    
    open lazy var mutable: [Type] = {
        return classesAndStructs.filter { $0.isMutable }
    }()
    open lazy var dataTypes: [Type] = {
        return classesAndStructs.filter { $0.isDataOnly }
    }()
    open lazy var stateLess: [Type] = {
        return classesAndStructs.filter { $0.isStateLess }
    }()
    
    open lazy var staticTypes: [Type] = {
        return classesAndStructs.filter { $0.isStatic }
    }()
    open lazy var instantiableStaticTypes = {
        return staticTypes.filter { $0.hasAccessibleInitializers }
    }()
    
    open lazy var views: [Class] = {
        return classes.filter { $0.isUIView }
    }()
    open lazy var viewControllers: [Class] = {
        return classes.filter { $0.isUIViewController }
    }()
    open lazy var nsobjects: [Class] = {
        return classes.filter { $0.isNSObject }
    }()
    
    open lazy var classInstanceVariables: [SourceryVariable] = {
        return classes.flatMap { $0.instanceVariables }
    }()
    
    open lazy var delegates: [SourceryVariable] = {
        return classInstanceVariables.filter { $0.isDelegate }
    }()

    open lazy var optionalReturnMethods: [SourceryMethod] = {
        return all.flatMap { $0.methodsWithOptionalReturn }
    }()

    open lazy var allDependencies: [Type: Set<String>] = {
        var allDependencies = [Type: Set<String>]()
        for type in all {
            allDependencies[type] = Type.allDependencies(type)
        }
        return allDependencies
    }()
    
    open lazy var knownDependencies: [Type: Set<Type>] = {
        var knownDependencies = [Type: Set<Type>]()
        for type in all {
            var ignoring = [Type]()
            knownDependencies[type] = Type.knownDependencies(type, ignoring: &ignoring, allKnownTypes: all)
        }
        return knownDependencies
    }()
    
    open lazy var unknownDependencies: [Type: Set<String>] = {
        var unknownDependencies = [Type: Set<String>]()
        for (type, dependencies) in allDependencies {
            let known = knownDependencies[type]?.map { $0.name } ?? [String]()
            let unknown = dependencies.filter { !known.contains($0) }
            unknownDependencies[type] = unknown
        }
        return unknownDependencies
    }()
    
    open lazy var incomingDependencies: [Type: Set<Type>] = {
        var incomings = [Type: Set<Type>]()
        for (type, dependencies) in knownDependencies {
            for dependency in dependencies {
                guard !dependency.isExtension else { continue }
                var incoming = incomings[dependency] ?? Set<Type>()
                incoming = setByInsertingNewMember(incoming, newMember: type)
                incomings[dependency] = incoming
            }
        }
        return incomings
    }()
    
    private func arrayByInsertingNewElement(_ array: [Type], newElement: Type) -> [Type] {
        var mutable = array
        mutable.append(newElement)
        return mutable
    }
    
    private func setByInsertingNewMember(_ set: Set<Type>, newMember: Type) -> Set<Type> {
        var mutable = set
        mutable.insert(newMember)
        return mutable
    }
}
