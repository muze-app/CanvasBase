//
//  LayerManager+Preview.swift
//  muze
//
//  Created by Greg on 1/29/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import MuzePrelude

struct MiscError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

extension LayerManager {
    
    func contentHash(for graph: Graph) -> Int? {
        return graph.subgraph(for: subgraphKey).finalNode?.contentHash
    }
    
    var previewIsUpToDate: Bool {
        guard let preview = preview else { return false }
        return preview.contentHash == contentHash(for: display)
    }
    
    func updatePreview() {
        let newContentHash = contentHash(for: display)
        
        if preview?.contentHash == newContentHash { return }
        if previewFuture.exists { return }
        
        if shouldSendPreview {
            generatePreview()
        }
    }
    
    var shouldSendPreview: Bool {
        return previewDelegate?.wantsUpdate ?? false
    }
    
    public func previewRequested() {
        if let preview = preview, previewIsUpToDate {
            previewDelegate?.layer(updated: preview)
        } else {
            generatePreview()
        }
    }
    
    @discardableResult
    func generatePreview() -> Future<LayerPreview> {
        guard let manager = canvasManager else { return .failed(MiscError("")) }
        
        let future = LayerPreviewRenderer.shared.render(layer: subgraphKey,
                                                        canvas: manager).hop(to: .main).map { [weak self] preview -> LayerPreview in
            try self?.received(preview)
            return preview
        }
        
        future.await { [weak self] result in
            print("result: \(result)")
             self?.previewFuture = nil
        }

        previewFuture = future
        
        return future
    }
    
    private func received(_ newPreview: LayerPreview) throws {
        if let oldPreview = preview, oldPreview.date > newPreview.date {
            throw MiscError("received older preview out of order")
        }
        
        previewDelegate?.layer(updated: newPreview)
        preview = newPreview
    }
    
}
