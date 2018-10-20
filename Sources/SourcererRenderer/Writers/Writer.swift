import Foundation

open class Writer {
    public init() {}
    
    open var lines = [String]()

    open func reset() {
        lines.removeAll()
    }

    open func write<T: TextOutputStream>(to stream: inout T) {
        let string = lines.joined(separator: "\n")
        stream.write(string)
    }

    open func write(url fileURL: URL) throws {
        let outString = lines.joined(separator: "\n")
        try outString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
