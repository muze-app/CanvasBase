//
//  CanvasMetaNode.swift
//  CanvasDAG
//
//  Created by Greg Fajen on 12/27/19.
//

public class CanvasMetaNode: PayloadNode<CanvasMetadata> {
    
    public init(_ key: NodeKey = NodeKey(), graph: Graph, payload: CanvasMetadata? = nil) {
        super.init(key, graph: graph, payload: payload, nodeType: .canvasMeta)
    }
    
}

public struct CanvasMetadata: NodePayload {
    
    public var width: Int
    public var height: Int
    public var size: CGSize {
        get { return CGSize(width: width, height: height) }
        set {
            width = Int(round(newValue.width))
            height = Int(round(newValue.height))
        }
    }
    public var bounds: CGRect { .zero & size }
    
    public var layers: [LayerKey] = []
    public var layerSubgraphs: [LayerKey:SubgraphKey] = [:]
    //    var rawSnapshots: [LayerKey:DAGSnapshot] = [:]
    //    var processedSnapshots: [LayerKey:DAGSnapshot] = [:]
    //    var sortedRawSnapshots: [DAGSnapshot] { return layers.map { rawSnapshots[$0]! } }
    //    var sortedProcessedSnapshots: [DAGSnapshot] { return layers.map { processedSnapshots[$0]! } }
    var selectedLayers = Set<LayerKey>()
    
    public var layerCount: Int { return layers.count }
    
    // do we have just one selected layer? none? many? let's pretend for now that there's always one and crash otherwise
    public var selectedLayer: LayerKey {
        get {
            assert(selectedLayers.count == 1)
            return selectedLayers.first!
        }
        
        set { selectedLayers = Set(newValue) }
    }
    
    public var selectedIndex: Int {
        get {
            return layers.index(of: selectedLayer)!
        }
        
        set {
            selectedLayer = layers[newValue]
        }
    }
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public init(size: CGSize) {
        width = Int(round(size.width))
        height = Int(round(size.height))
    }
    
    #if os(iOS)
    // probably obselete but will stick around for now
    var backgroundColor: UIColor { return .white }
    var backgroundIsHidden: Bool { return true }
    #endif
    
}

//extension DAGSnapshot: Equatable {
//
//    public static func == (l: DAGSnapshot, r: DAGSnapshot) -> Bool {
//        return l.key == r.key
//    }
//
//}
//
//extension DAGSnapshot: Hashable {
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(key)
//    }
//
//}
