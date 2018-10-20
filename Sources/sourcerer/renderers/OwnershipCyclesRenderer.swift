import Foundation
import SourceryRuntime
import SourcererTypes
import SourcererRenderer
import ElementaryCycles
import Idioms

final class OwnershipCyclesRenderer: AbstractRenderer<GraphViz> {
    public init(types: Types) {
        super.init(types: types, writer: GraphViz())
    }

    public override var filename: String {
        return "cycles.dot"
    }

    override func render() {
        let graph = buildGraph(for: classesAndStructs)
        let cycles = ElementaryCycles.find(graph: graph) { $0 > $1 }
        writer.writeOpening()
        if cycles.isEmpty {
            let message = "There aren't any cycles"
            writer.writeArrow(fromNode: message, toNode: message)
        } else {
            writeArrows(for: cycles)
        }
        writer.writeClosing()
    }

    private func buildGraph(for types: [Type]) -> [String: [String]] {
        var graph = [String: [String]]()
        for type in types {
            var nodes = [String]()
            for variable in type.instanceVariables {
                guard let varType = variable.type, !varType.isExtension else { continue }
                nodes.append(varType.name)
            }
            graph[type.name] = nodes
        }
        return graph
    }

    private func writeArrows(for cycles: [[String]]) {
        for cycle in cycles {
            cycle.iterate { cycle, index in
                if let nextIndex = index.next {
                    let current = cycle[index.current]
                    let next = cycle[nextIndex]
                    writer.writeArrow(fromNode: current, toNode: next)
                } else if let first = cycle.first {
                    let current = cycle[index.current]
                    writer.writeArrow(fromNode: current, toNode: first)
                }
            }
        }
    }
}
