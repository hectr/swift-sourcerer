import Foundation

open class Markdown: Writer {
    open func writeLine(_ line: String = "") {
        lines += [line]
    }
    
    open func writeTitle(_ title: String, level: Int = 0) {
        writeLine()
        writeLine("\(String(repeating: "#", count: level + 1)) \(title)")
    }
    
    open func writeAsList(_ array: [String],
                          bullet: String = "-",
                          level: Int = 0,
                          maxCount: Int = 8) {
        guard !array.isEmpty else { return }
        writeLine()
        for item in array.prefix(maxCount) {
            writeLine("\(String(repeating: " ", count: level*4))\(bullet) \(item)")
        }
        if maxCount < array.count {
            writeLine("\(String(repeating: " ", count: level*4))\(bullet) …")
        }
    }
}
