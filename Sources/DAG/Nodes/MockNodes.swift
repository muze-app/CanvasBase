//
//  MockNodes.swift
//  canvas-base
//
//  Created by Greg Fajen on 12/20/19.
//

import Foundation

public enum MockNodeCollection: NodeCollection {
    
    case image, blend, filter
    
    public func node(for key: NodeKey, graph: DAGBase<MockNodeCollection>) -> GenericNode<MockNodeCollection> {
        switch self {
            case .image: return MockImageNode(key, graph: graph)
            case .blend: return MockBlendNode(key, graph: graph)
            case .filter: return MockFilterNode(key, graph: graph)
        }
    }
    
    public typealias RenderPayloadType = Void
    public typealias RenderOptionsType = Void
    public typealias RenderExtentType = Void
    public typealias UserExtentType = Void
    
}

public class MockImageNode: GeneratorNode<MockNodeCollection, MockNodePayload> {
    
}

public class MockBlendNode: PayloadNode<MockNodeCollection, MockNodePayload> {
    
    public var source: Node? {
        get { return nodeInputs[0] }
        set { nodeInputs[0] = newValue }
    }
    
    public var destination: Node? {
        get { return nodeInputs[1] }
        set { nodeInputs[1] = newValue }
    }
    
}

public class MockFilterNode: INode<MockNodeCollection, MockNodePayload> {
    
}

public struct MockNodePayload: NodePayload, ExpressibleByIntegerLiteral {
    
    let int: Int
    
    public init(_ value: Int) { int = value }
    public init(integerLiteral value: Int) { int = value }
    
    public func transformed(by transform: AffineTransform) -> MockNodePayload {
        self
    }
    
}
