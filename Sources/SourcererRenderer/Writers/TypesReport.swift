import Foundation
import SourceryRuntime

open class TypesReport: Markdown {
    public struct TypeCounter {
        public var type: Type?
        public var count: Int = .min
        
        public init() { }
        
        public init(type: Type?, count: Int) {
            self.type = type
            self.count = count
        }
        
        public init(type: Type?, counting: [Any]) {
            self.type = type
            self.count = counting.count
        }
    }

    // MARK: - TypeCounter writing
    
    open func writeCounter(_ counter: TypeCounter, label: String) {
        guard let type = counter.type else { return }
        writeLine()
        writeLine("\(label):\n`\(type.name)` (\(counter.count))")
    }
    
    // MARK: - Type arrays writing
    
    open func write(title: String? = nil,
                    titleLevel: Int = 1,
                    types: [Type],
                    label: String,
                    disclosePrivate: Bool = false,
                    listBullet: String = "-",
                    listLevel: Int = 0,
                    maxCount: Int = 8,
                    sortCriteria: (Type) -> Int = { $0.methods.count }) {
        if let title = title {
            writeTitle(title, level: titleLevel)
        }
        if disclosePrivate {
            writeCount(of: types,
                       label: label,
                       subset: types.filter {
                        AccessLevel.isNonAccessible(rawValue: $0.accessLevel)
                       },
                       subsetLabel: "private")
        } else {
            writeLine()
            writeLine("There are **\(types.count) \(label)** types.")
        }
        writeAsList(types, bullet: listBullet, level:listLevel, maxCount: maxCount, sortCriteria: sortCriteria)
    }
    
    open func write(title: String? = nil,
                    titleLevel: Int = 1,
                    types: [Type],
                    label: String,
                    subset: [Type],
                    subsetLabel: String,
                    listBullet: String = "-",
                    listLevel: Int = 0,
                    maxCount: Int = 8,
                    sortCriteria: (Type) -> Int = { $0.methods.count }) {
        if let title = title {
            writeTitle(title, level: titleLevel)
        }
        writeCount(of: types, label: label, subset: subset, subsetLabel: subsetLabel)
        writeAsList(types, bullet: listBullet, level:listLevel, maxCount: maxCount, sortCriteria: sortCriteria)
    }
    
    open func writeCount(of types: [Type],
                         label: String,
                         disclosePrivate: Bool = false) {
        if disclosePrivate {
            writeCount(of: types,
                       label: label,
                       subset: types.filter {
                        AccessLevel.isNonAccessible(rawValue: $0.accessLevel)
                       },
                       subsetLabel: "private")
        } else {
            writeLine()
            writeLine("There are **\(types.count) \(label)** types.")
        }
    }
    
    open func writeCount(of types: [Type],
                         label: String,
                         subset: [Type],
                         subsetLabel: String) {
        writeLine()
        writeLine("There are **\(types.count) \(label)** types (of which \(subset.count) are \(subsetLabel)).")
    }
    
    open func writeAsList(_ types: [Type],
                          bullet: String = "-",
                          level: Int = 0,
                          maxCount: Int = 8,
                          sortCriteria: (Type) -> Int = { $0.methods.count }) {
        return writeAsList(types.sorted { sortCriteria($0) > sortCriteria($1) }.map { $0.name }, bullet: bullet, level: level, maxCount: maxCount)
    }
    
    open func writeAsList(_ counters: [TypeCounter],
                          bullet: String = "-",
                          level: Int = 0,
                          maxCount: Int = 8,
                          sortCriteria: (TypeCounter) -> Int = { $0.count }) {
        return writeAsList(counters.sorted { sortCriteria($0) > sortCriteria($1) }.compactMap { $0.type?.name },
                           bullet: bullet,
                           level: level,
                           maxCount: maxCount)
    }
}
