//
//  BlackCoverView.swift
//  muze
//
//  Created by Greg Fajen on 12/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

#if os(iOS)
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
#endif

public struct NewCameraCanvasLayout {
    
    // set to MainVC.shared.view
    #if os(iOS)
    public static var mainView: UIView!
    #endif
    
    public var isX: Bool {
        #if os(iOS)
        return UIDevice.current.isX
        #else
        return false
        #endif
    }
    
    public var topMargin:    CGFloat { isX ?       44 : 0 }
    public var bottomMargin: CGFloat { isX ? 188 + 34 : 188 }
    
    public var bottomSafety: CGFloat {
        #if os(iOS)
        return NewCameraCanvasLayout.mainView!.safeAreaInsets.bottom
        #else
        return 0
        #endif
    }
    
    public var rect: CGRect {
        #if os(iOS)
        return CGRect.screen.inset(by: .init(top: topMargin, left: 0, bottom: bottomMargin, right: 0))
        #else
        return CGRect(x: 0, y: 0, width: 2048, height: 2048)
        #endif
    }
    
    public var aspectRatio: CGFloat { rect.aspectRatio }
    
    public var cornerRadius: CGFloat { 16 }
    
    public var nativeScale: CGFloat {
        #if os(iOS)
        return UIScreen.main.nativeScale
        #else
        return 1
        #endif
    }
    
    public var canvasSize: CGSize {
        var size = rect.size * nativeScale
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        return size
    }
    
    public init() { }
    
}

#if os(iOS)
public extension UIDevice {
    
    var mainView: UIView! { NewCameraCanvasLayout.mainView }
    
    var isX: Bool {
        guard let mainView = mainView else { return false }
        return mainView.safeAreaInsets.top > 20
    }
    
}
#endif
