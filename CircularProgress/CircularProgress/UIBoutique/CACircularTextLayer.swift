//
//  CACircularTextLayer.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2017-03-24.
//  Copyright © 2017 Victor Obretin. All rights reserved.
//

import UIKit

class CACircularTextLayer: CALayer {
    
    var textValue: String = "CIRCULAR TEXT"
    var textColor: UIColor = UIColor.white
    var textSize: CGFloat = 16.0
    var radius: CGFloat = 100.0
    var angle: CGFloat = 0.0
    var allignedToEnd: Bool = false
    var endSpacing: CGFloat = 0.0
    
    private var _context: CGContext?
    private var _image: UIImage?
    
    func drawString() {
        let size = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        _context = UIGraphicsGetCurrentContext()
        
        if (_context == nil) {
            return
        }
        
        _context!.translateBy (x: size.width / 2.0, y: size.height / 2.0)
        _context!.scaleBy (x: 1, y: -1)
        
        drawInPlace(text: textValue, context: _context!, radius: radius, angle: angle, color: textColor, font: UIFont.boldSystemFont(ofSize: textSize), clockwise: true)
        
        _image = UIGraphicsGetImageFromCurrentImageContext()
        self.contents = _image?.cgImage
        
        UIGraphicsEndImageContext()
    }
    
    private func drawInPlace(text str: String, context: CGContext, radius: CGFloat, angle theta: CGFloat, color: UIColor, font: UIFont, clockwise: Bool) {
        let charactersCount = str.characters.count
        let attributes = [NSFontAttributeName: font]
        
        let characters: [String] = str.characters.map { String($0) }
        var arcs: [CGFloat] = []
        var totalArc: CGFloat = 0
        
        for i in 0 ..< charactersCount {
            arcs += [chordToArc(characters[i].size(attributes: attributes).width, radius: radius)]
            totalArc += arcs[i]
        }
        
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -(CGFloat.pi / 2.0)  : (CGFloat.pi / 2.0)
        
        var thetaI = allignedToEnd ? (theta - direction * totalArc + endSpacing) : ((CGFloat.pi / 2.0) - endSpacing)
        
        for i in 0 ..< charactersCount {
            thetaI += direction * arcs[i] / 2
            centre(text: characters[i], context: context, radius: radius, angle: thetaI, color: color, font: font, slantAngle: thetaI + slantCorrection)
            thetaI += direction * arcs[i] / 2
        }
    }
    
    private func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
    }
    
    private func centre(text str: String, context: CGContext, radius:CGFloat, angle theta: CGFloat, color: UIColor, font: UIFont, slantAngle: CGFloat) {
        let attributes = [NSForegroundColorAttributeName: color,
                          NSFontAttributeName: font]
        context.saveGState()
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: radius * cos(theta), y: -(radius * sin(theta)))
        context.rotate(by: -slantAngle)
        let offset = str.size(attributes: attributes)
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        context.restoreGState()
    }
    
}
