import Foundation

open class GraphEasy: Writer {
    open func writeOpening(filename: String = "example.txt") {
        let name = (filename as NSString).deletingPathExtension
        lines += [""]
        lines +=
["""
################################################################################
#
# Generated with https://github.com/hectr/swift-sourcerer
# Visualize with http://bloodgate.com/perl/graph
#
# Output examples:
#
# $ graph-easy \(filename) --as svg > \(name).svg
# $ graph-easy \(filename) --as boxart > \(name).ascii
# $ graph-easy \(filename)
#
# Install required modules:
#
# $ cpan App::cpanminus
# $ cpan Graph::Easy
# $ cpan Graph::Easy::As_svg
#
################################################################################
"""]
        lines += [""]
    }

    // TODO: customize arrow head, edge and nodes (shape and color)
    open func writeArrow(fromNode left: String, toNode right: String, color: X11Color = .black) {
        lines += ["[\(left)] =>{ color: \(color.rawValue); } [\(right)]"]
    }
    
    open func writeClosing() {
        lines += [""]
    }
}
