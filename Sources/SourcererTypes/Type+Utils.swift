import Foundation
import SourceryRuntime

public extension Type {
    var allInstanceVariables: [SourceryVariable] {
        return allVariables.filter { !$0.isStatic }
    }
    
    var allStaticVariables: [SourceryVariable] {
        return allVariables.filter { $0.isStatic }
    }
    
    var allInstanceMethods: [SourceryMethod] {
        return allMethods.filter { !$0.isStatic && !$0.isClass }
    }
    
    var allNonInstanceMethods: [SourceryMethod] {
        return allMethods.filter { $0.isStatic || !$0.isClass }
    }
    
    var allInitializers: [SourceryMethod] {
        return allMethods.filter { $0.isInitializer }
    }
    
    var nonInstanceMethods: [SourceryMethod] {
        return methods.filter { $0.isStatic || !$0.isClass }
    }
    
    var hasAccessibleInitializers: Bool {
        guard !AccessLevel.isNonAccessible(rawValue: accessLevel) else { return false }
        if allInitializers.isEmpty {
            return self is Class || self is Struct
        }
        return !allInitializers.filter { AccessLevel.isAccessible(rawValue: $0.accessLevel) }.isEmpty
    }
    
    var isSingleton: Bool {
        guard self is Class || self is Struct else { return false }
        guard !hasAccessibleInitializers else { return false }
        guard staticInstances == 1 else { return false }
        return true
    }
    
    var staticInstances: Int {
        let accessibleStaticGetters = allStaticVariables.filter { staticVariable in
            guard let variableType = staticVariable.type else { return false }
            guard variableType == self else { return false }
            guard staticVariable.isComputed || !staticVariable.isMutable else { return false }
            guard !AccessLevel.isAccessible(rawValue: staticVariable.writeAccess) else { return false }
            guard !AccessLevel.isNonAccessible(rawValue: staticVariable.readAccess) else { return false }
            return true
        }
        return accessibleStaticGetters.count
    }
    
    var isExposingMutableInstanceVars: Bool {
        for variable in allInstanceVariables where variable.isMutable{
            if AccessLevel.isAccessible(rawValue: variable.writeAccess) {
                return true
            }
        }
        return false
    }
    
    var isMutable: Bool {
        for variable in allInstanceVariables where variable.isMutable {
            return true
        }
        for method in allInstanceMethods {
            for attribute in method.attributes {
                guard let attributeId = Attribute.Identifier.from(string: attribute.key) else { continue }
                switch attributeId {
                case .mutating: return true
                case .lazy, .convenience, .required, .available, .discardableResult, .GKInspectable, .objc, .objcMembers, .nonobjc, .NSApplicationMain, .NSCopying, .NSManaged, .UIApplicationMain, .IBOutlet, .IBInspectable, .IBDesignable, .autoclosure, .convention, .escaping, .final, .open, .public, .internal, .private, .fileprivate, .publicSetter, .internalSetter, .privateSetter, .fileprivateSetter: continue
                }
            }
        }
        return false
    }
    
    var isNested: Bool {
        return parentName != nil
    }
    
    var nestingLevel: Int {
        guard let parent = parent else { return 0 }
        return 1 + parent.nestingLevel
    }
    
    var inheritanceLevel: Int {
        guard let parent = supertype else { return 0 }
        return 1 + parent.inheritanceLevel
    }
    
    var isDataOnly: Bool {
        guard self is Class || self is Struct else { return false }
        for method in allMethods {
            guard method.returnType != self else { continue }
            guard !AccessLevel.isNonAccessible(rawValue: method.accessLevel) else { continue }
            return false
        }
        return true
    }
    
    var isStateLess: Bool {
        guard self is Class || self is Struct else { return false }
        return allInstanceVariables.isEmpty
    }
    
    var isStatic: Bool {
        guard self is Class || self is Struct else { return false }
        return isExtension == false &&
            allInstanceMethods.isEmpty &&
            allInstanceVariables.isEmpty &&
            allInitializers.isEmpty
    }
    
    var namesOfBaseTypes: Set<String> {
        var names = Set<String>()
        if let supertype = supertype {
            supertype.namesOfBaseTypes.forEach { names.insert($0) }
        }
        for (_, inheritedType) in inherits {
            inheritedType.namesOfBaseTypes.forEach { names.insert($0) }
        }
        for (_, value) in based {
            names.insert(value)
        }
        return names
    }
    
    static func allDependencies(_ type: Type, allTypes: [Types] = []) -> Set<String> {
        var ignoring = [Type]()
        let dependencies = allDependencies(type, ignoring: &ignoring)
        var names = Set<String>()
        for dependency in dependencies {
            let unwrappedName = dependency.unwrappedTypeName
            let components = unwrappedName.components(separatedBy: "<").flatMap { $0.components(separatedBy: ">") }
            components.forEach { names.insert($0) }
        }
        return names
    }
    
    static func allDependencies(_ type: Type, ignoring: inout [Type]) -> Set<TypeName> {
        guard !ignoring.contains(type) else { return Set<TypeName>() }
        ignoring += [type]
        var dependencies = [TypeName]()
        if let enumType = type as? Enum {
            if let rawTypeName = enumType.rawTypeName {
                dependencies += [rawTypeName]
            } else {
                dependencies += enumType.cases.flatMap { $0.associatedValues }.map { $0.typeName }
            }
        }
        dependencies += type.subscripts.flatMap { $0.parameters }.map { $0.typeName }
        dependencies += type.typealiases.map { $0.value.typeName }
        dependencies += type.allVariables.map { $0.typeName }
        dependencies += type.allMethods.flatMap { $0.parameters }.map { $0.typeName }
        dependencies += dependencies.compactMap { $0.closure }.flatMap { $0.parameters }.map { $0.typeName }
        dependencies += dependencies.compactMap { $0.tuple }.flatMap { $0.elements }.map { $0.typeName }
        dependencies += dependencies.compactMap { $0.array?.elementTypeName }
        dependencies += dependencies.compactMap { $0.dictionary }.flatMap { [$0.keyTypeName, $0.valueTypeName] }
        dependencies += dependencies.compactMap { $0.generic?.typeParameters.compactMap { $0.typeName } }.flatMap { $0 }
        if let supertype = type.supertype {
            dependencies += allDependencies(supertype, ignoring: &ignoring)
        }
        if let parent = type.parent {
            dependencies += allDependencies(parent, ignoring: &ignoring)
        }
        for inherited in type.inherits.map({ $0.value }) {
            dependencies += allDependencies(inherited, ignoring: &ignoring)
        }
        for implemented in type.implements.map({ $0.value }) {
            dependencies += allDependencies(implemented, ignoring: &ignoring)
        }
        dependencies = dependencies.map { $0.actualTypeName ?? $0 }
        dependencies = dependencies.filter { !$0.isVoid && !$0.isArray && !$0.isClosure && !$0.isDictionary }
        return Set(dependencies)
    }
    
    static func unknownDependencies(_ type: Type, allKnownTypes: [Type]) -> Set<String> {
        let known = knownDependencies(type, allKnownTypes: allKnownTypes)
        return allDependencies(type).filter { !known.contains($0) }
    }
    
    static func knownDependencies(_ type: Type, allKnownTypes: [Type]) -> Set<String> {
        var ignoring = [Type]()
        let types = knownDependencies(type, ignoring: &ignoring, allKnownTypes: allKnownTypes)
        var names = Set<String>()
        for type in types {
            names.insert(type.name)
        }
        return names
    }
    
    static func knownDependencies(_ type: Type, ignoring: inout [Type], allKnownTypes: [Type]) -> Set<Type> {
        guard !ignoring.contains(type) else { return Set<Type>() }
        ignoring += [type]
        var types = [Type]()
        if let enumType = type as? Enum {
            if let rawType = enumType.rawType {
                types += [rawType]
            } else {
                types += enumType.cases.flatMap { $0.associatedValues }.compactMap { $0.type }
            }
        }
        types += type.subscripts.flatMap { $0.parameters }.compactMap { $0.type }
        types += type.typealiases.compactMap { $0.value.type }
        types += type.allVariables.compactMap { $0.type }
        types += type.allMethods.flatMap { $0.parameters }.compactMap { $0.type }
        if let supertype = type.supertype {
            types += knownDependencies(supertype, ignoring: &ignoring, allKnownTypes: allKnownTypes)
        }
        if let parent = type.parent {
            types += knownDependencies(parent, ignoring: &ignoring, allKnownTypes: allKnownTypes)
        }
        for inherited in type.inherits.map({ $0.value }) {
            types += knownDependencies(inherited, ignoring: &ignoring, allKnownTypes: allKnownTypes)
        }
        for implemented in type.implements.map({ $0.value }) {
            types += knownDependencies(implemented, ignoring: &ignoring, allKnownTypes: allKnownTypes)
        }
        var ignoringCopy = ignoring
        let typeNames = allDependencies(type, ignoring: &ignoringCopy)
        types += typeNames.compactMap { $0.closure }.flatMap { $0.parameters }.compactMap { $0.type }
        types += typeNames.compactMap { $0.closure }.flatMap { $0.parameters }.compactMap { $0.type }
        types += typeNames.compactMap { $0.tuple }.flatMap { $0.elements }.compactMap { $0.type }
        types += typeNames.compactMap { $0.array?.elementType }
        types += typeNames.compactMap { $0.dictionary }.flatMap { [$0.keyType, $0.valueType] }.compactMap { $0 }
        types += typeNames.compactMap { $0.generic?.typeParameters.compactMap { $0.type } }.flatMap { $0 }
        return Set(types)
    }
}
