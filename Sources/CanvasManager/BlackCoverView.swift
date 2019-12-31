//
//  BlackCoverView.swift
//  muze
//
//  Created by Greg Fajen on 12/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit

class BlackCoverView: UIView {
    
    init() {
        super.init(frame: .screen)
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var radius: CGFloat = 100
    var rect: CGRect = .screen
    var bezierPath: UIBezierPath { .init(roundedRect: rect, cornerRadius: radius) }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        UIRectFill(bounds)
        bezierPath.fill(with: .clear, alpha: 1)
    }
    
}

struct NewCameraCanvasLayout {
    
    // set to MainVC.shared.view
    static var mainView: UIView!
    
    var isX: Bool { UIDevice.current.isX }
    
    var topMargin:    CGFloat { isX ?       44 : 0 }
    var bottomMargin: CGFloat { isX ? 188 + 34 : 188 }
    
    var bottomSafety: CGFloat { NewCameraCanvasLayout.mainView!.safeAreaInsets.bottom }
    
    var rect: CGRect { CGRect.screen.inset(by: .init(top: topMargin, left: 0, bottom: bottomMargin, right: 0))}
    
    var aspectRatio: CGFloat { rect.aspectRatio }
    
    var cornerRadius: CGFloat { 16 }
    
    var nativeScale: CGFloat { UIScreen.main.nativeScale }
    
    var canvasSize: CGSize {
        var size = rect.size * nativeScale
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        return size
    }
    
}

public extension UIDevice {
    
    var mainView: UIView! { NewCameraCanvasLayout.mainView }
    
    var isX: Bool {
        guard let mainView = mainView else { return false }
        return mainView.safeAreaInsets.top > 20
    }
    
}
