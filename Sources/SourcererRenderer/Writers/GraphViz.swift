import Foundation

open class GraphViz: Writer {
    open func writeOpening(digraph: String = "GRAPH_0",
                           arrowhead: ArrowHead = .open,
                           rankdir: Direction = .leftToRight,
                           fillcolor: X11Color = .white,
                           fontsize: Int = 11,
                           shape: NodePolygonShape = .box,
                           style: NodeStyle = .filled) {
        lines += ["digraph GRAPH_0 {"]
        lines += [""]
        lines += ["  // Generated with https://github.com/hectr/swift-sourcerer"]
        lines += ["  // Visualize with https://www.graphviz.org"]
        lines += [""]
        lines +=
["""
  edge [ arrowhead=\(arrowhead.rawValue) ];
  graph [ rankdir=\(rankdir.rawValue) ];
  node [
    fillcolor=\(fillcolor.rawValue),
    fontsize=\(fontsize),
    shape=\(shape.rawValue),
    style=\(style.rawValue) ];
"""]
        lines += [""]
    }

    // TODO: customize arrow head, edge and nodes (shape and color)
    open func writeArrow(fromNode left: String, toNode right: String, color: X11Color = .black) {
        lines += ["  \"\(left)\" -> \"\(right)\" [ color=\"\(color.rawValue)\" ]"]
    }
    
    open func writeClosing() {
        lines += ["}"]
    }
}
