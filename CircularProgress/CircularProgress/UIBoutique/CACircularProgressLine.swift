//
//  CACircularLineLayer.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-12-02.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import UIKit

class CACircularProgressLine: CAShapeLayer {
    
    private var _startAngle: CGFloat = -90
    private var _lineColor: UIColor = UIColor.black
    private var _drawClockwise: Bool = true
    
    public var startAngle: CGFloat {
        get {
            return _startAngle
        }
        set {
            _startAngle = newValue
        }
    }
    
    public var drawClockwise: Bool {
        get {
            return _drawClockwise
        }
        set {
            _drawClockwise = newValue
        }
    }
    
    public func drawPath() {
        let startAngle = 2.0 * CGFloat.pi * (_startAngle / 360.0)
        let endAngle = startAngle + (2.0 * CGFloat.pi)
        
        let minSize = min(bounds.width, bounds.height)
        
        if (minSize <= 0) {
            return
        }
        
        let adjustedOrigin = CGPoint(x: bounds.origin.x + (bounds.width - minSize) / 2.0, y: bounds.origin.y + (bounds.height - minSize) / 2.0)
        let minBounds = CGRect.init(origin: adjustedOrigin, size: CGSize.init(width: minSize, height: minSize))
        let rect = minBounds.insetBy(dx: self.lineWidth / 2.0, dy: self.lineWidth / 2.0)
        let center = CGPoint.init(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0)
        let path = UIBezierPath(arcCenter: center, radius: rect.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: _drawClockwise)
        
        self.path = path.cgPath
        self.fillColor = UIColor.clear.cgColor
        self.lineJoin = kCALineJoinRound
    }
}
