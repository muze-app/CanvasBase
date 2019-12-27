//
//  CompositionNode.swift
//  muze
//
//  Created by Greg Fajen on 5/19/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import Foundation
import DAG

public class CompositeNode: ListNode<Float> {

    init(_ key: NodeKey = NodeKey(), graph: Graph, payload: [Float]? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .comp)
    }

//    override var worthCaching: Bool { return true }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return inputs.reduce(.nothing) { $0.union(with: $1.renderExtent) }
//    }
//
//    override var calculatedUserExtent: UserExtent {
//        return inputs.reduce(.nothing) { $0.union(with: $1.userExtent) }
//    }
//
//    override func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        let composite = RenderIntermediate(identifier: "\(self)", options: options, extent: renderExtent)
//
//        if !composite.extent.basic.exists {
//            print(" no basic extent? \(composite.extent)")
//            for input in inputs {
//                print("    - \(input.renderExtent) \(input)")
//            }
//            print("hmmm")
//        }
//
//        for (alpha, input) in pairs.reversed() {
//            guard let payload = input?.renderPayload(for: options), alpha > 0 else { continue }
//
//            let identifier: String
//            if let t = payload.texture {
//                identifier = "Draw \(t.pointerString)"
//            } else if let i = payload.intermediate {
//                identifier = "Draw \(i.identifier)"
//            } else {
//                identifier = "Draw...something"
//            }
//
//            if alpha == 1, let intermediate = payload.intermediate, intermediate.canAlias, intermediate.passes.count == 1 {
//                let pass = intermediate.passes[0]
//                pass.transform(by: payload.getTransform)
//                composite << pass
//            } else {
//                composite << RenderPassDescriptor(identifier: identifier,
//                                                  pipeline: .drawPipeline2,
//                                                  input: .alpha(payload, alpha))
//            }
//        }
//
//        return composite.payload
//    }
//
//    override var possibleOptimizations: [OptFunc] {
//        return [combine, invisibles, justOne]
//    }
//
//    var combine: OptFunc { return { CombineCompositesOpt($0) } }
//    var invisibles: OptFunc { return { RemoveInvisiblesFromCompositeOpt($0) } }
//    var justOne: OptFunc { return { SimplifyUnaryCompositeOpt($0) } }

}

final class CombineCompositesOpt: Optimization {

    var compositeNode: CompositeNode? {
        return left as? CompositeNode
    }

    override var isValid: Bool {
        guard let compositeNode = self.compositeNode else {
            return false
        }

        let graph = compositeNode.graph
        for (alpha, key) in zip(compositeNode.payload, compositeNode.sortedEdges.map { $0.1 }) {
            if alpha != 1 { continue }
            if graph.type(for: key) == .comp { return true }
        }

        return false
    }

    override func setupTarget(graph: MutableGraph) {
        let old = compositeNode!
        let new = CompositeNode(graph: graph, payload: [])

        new.pairs = old.pairs.flatMap { (alpha, input) -> [(Float, Node?)] in
            guard let input = input else { return [] }

            if alpha != 1 { return [(alpha, input)] }

            if let comp = input as? CompositeNode {
                return comp.pairs
            }

            return [(1, input)]
        }

        right = new
    }

}

class RemoveInvisiblesFromCompositeOpt: Optimization {

    var compositeNode: CompositeNode? {
        return left as? CompositeNode
    }

    override var isValid: Bool {
        guard let composite = compositeNode else { return false }

        for input in composite.inputs where input.isInvisible {
            return true
        }

        return false
    }

    override func setupTarget(graph: MutableGraph) {
        let old = compositeNode!
        let new = CompositeNode(graph: graph, payload: [])

        new.pairs = old.pairs.compactMap {
            let (alpha, input) = $0
            if input?.isInvisible ?? true { return nil }
            return (alpha, input)
        }

        right = new
    }

}

class SimplifyUnaryCompositeOpt: Optimization {

    var compositeNode: CompositeNode? {
        return left as? CompositeNode
    }

    override var isValid: Bool {
        return compositeNode?.inputCount ?? 0 == 1
    }

    override func setupTarget(graph: MutableGraph) {
        let compositeNode = self.compositeNode!
        let (i, key) = compositeNode.edgeMap.first!
        let alpha = compositeNode.payload[i]
        let node = graph.node(for: key)

        if alpha == 1 {
            right = node
        } else {
            let alpha = AlphaNode(graph: graph, payload: alpha)
            alpha.input = node
            right = alpha
        }
    }

}
