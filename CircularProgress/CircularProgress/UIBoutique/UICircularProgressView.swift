//
//  UICircularProgressView.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-11-21.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import UIKit

protocol CircularProgressViewDelegate: class {
    func onCircularProgressValueWillUpdate(value: CGFloat, index: Int)
    func onCircularProgressValueUpdated(value: CGFloat, index: Int)
}

@IBDesignable
class UICircularProgressView: UIView {
    
    @IBInspectable var progressValue: CGFloat = 0.0
    
    @IBInspectable var lineWidth: CGFloat = 20.0
    @IBInspectable var lineColor: UIColor = UIColor.black
    
    @IBInspectable var showTrack: Bool = false
    @IBInspectable var trackWidth: CGFloat = 20
    @IBInspectable var trackColor: UIColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1)
    @IBInspectable var trackProgress: CGFloat = 1.0
    
    @IBInspectable var animationDuration: Double = 1.5
    @IBInspectable var animationDelay: Double = 0.0
    
    @IBInspectable var showValueLabel: Bool = false
    @IBInspectable var name:String = ""
    @IBInspectable var labelColor: UIColor = UIColor.white
    @IBInspectable var labelScale: CGFloat = 1
    @IBInspectable var roundEnds: Bool = false
    
    private let kReferenceLineWidth: CGFloat = 20.0
    private let kReferenceFontSize: CGFloat = 14.0
    private let kEndSpacing: CGFloat = 0.01
    
    public var delegate: CircularProgressViewDelegate?
    public var index: Int = 0
    
    private var _circularProgressLine: CACircularProgressLine?
    private var _circularTrack: CACircularProgressLine?
    private var _nameLabelLayer: CACircularTextLayer?
    private var _valueLabelLayer: CACircularTextLayer?
    
    private var _displayLink: CADisplayLink?
    private var _delayStartTime: TimeInterval = 0
    private var _animationStartTime: TimeInterval = 0

    private var _oldProgressValue: CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateProgressLine(value: progressValue, animated: false)
        
        if (progressValue <= 0) {
            _valueLabelLayer?.opacity = 0.0
            _nameLabelLayer?.opacity = 0.0
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        updateProgressLine(value: progressValue, animated: false)
        
        _valueLabelLayer?.opacity = 1.0
        _nameLabelLayer?.opacity = 1.0
    }
    
    public func setProgressValue(value: CGFloat, animated: Bool = true, newColor: UIColor? = nil) {
        stopLoop()
        
        _oldProgressValue = progressValue
        progressValue = value
        
        updateProgressLine(value: value, animated: animated, newColor: newColor)
    }
    
    private func updateProgressLine(value: CGFloat, animated: Bool = true, newColor: UIColor? = nil) {
        if (delegate != nil) {
            delegate?.onCircularProgressValueWillUpdate(value: value, index: index)
        }
        
        var clampedValue: CGFloat = value
        if (clampedValue < 0) {
            clampedValue = 0
        } else if (clampedValue > 1.0) {
            clampedValue = 1.0
        }
        
        var graphicsBounds:CGRect = self.bounds
        let minSize:CGFloat = min(graphicsBounds.size.width, graphicsBounds.size.height)
        
        graphicsBounds.origin.x = (self.bounds.size.width - minSize) / 2.0
        graphicsBounds.origin.y = (self.bounds.size.height - minSize) / 2.0
        graphicsBounds.size.width = minSize
        graphicsBounds.size.height = minSize
        
        updateTrack()
        updateCircularProgressLine(value: clampedValue, graphicsBounds: graphicsBounds, animated: animated, newColor: newColor)
        
        let scaleRatio: CGFloat = lineWidth / kReferenceLineWidth
        
        updateValueLabel(value: clampedValue, graphicsBounds: graphicsBounds, scaleRatio: scaleRatio, animated: animated)
        updateNameLabel(value: clampedValue, graphicsBounds: graphicsBounds, scaleRatio: scaleRatio, animated: animated)
    }
    
    private func updateTrack() {
        if (showTrack) {
            
            if (_circularTrack == nil) {
                _circularTrack = CACircularProgressLine()
                self.layer.addSublayer(_circularTrack!)
            }
            
            let trackBounds = self.bounds
            let adjustedBounds = trackBounds.insetBy(dx: (lineWidth - trackWidth) / 2.0, dy: (lineWidth - trackWidth) / 2.0)
            
            _circularTrack?.frame = adjustedBounds
            _circularTrack?.lineWidth = trackWidth
            _circularTrack?.strokeColor = trackColor.cgColor
            _circularTrack?.drawPath()
            
        } else if (_circularTrack != nil && !showTrack) {
            _circularTrack?.removeFromSuperlayer()
            _circularTrack = nil
        }
    }
    
    private func updateCircularProgressLine(value: CGFloat, graphicsBounds: CGRect, animated: Bool = true, newColor: UIColor? = nil) {
        if (_circularProgressLine == nil) {
            _circularProgressLine = CACircularProgressLine()
            self.layer.addSublayer(_circularProgressLine!)
        }
        
        _circularProgressLine?.removeAllAnimations()
        
        _circularProgressLine?.frame = graphicsBounds
        _circularProgressLine?.lineWidth = lineWidth
        _circularProgressLine?.lineCap = roundEnds ? kCALineCapRound : kCALineCapButt
        _circularProgressLine!.strokeEnd = (animated && animationDuration > 0) ? _oldProgressValue : value
        _circularProgressLine?.strokeColor = (newColor != nil && (!animated || animationDuration <= 0)) ? newColor!.cgColor : lineColor.cgColor
        _circularProgressLine?.drawPath()
        
        if (animated && animationDuration > 0) {
            
            let colorAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeColor")
            colorAnimation.fromValue = lineColor.cgColor
            if (newColor != nil) {
                colorAnimation.toValue = newColor?.cgColor
            }
            
            let strokeEndAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeEndAnimation.fromValue = _oldProgressValue
            strokeEndAnimation.toValue = value
            
            let animationGroup: CAAnimationGroup = CAAnimationGroup()
            animationGroup.animations = [colorAnimation, strokeEndAnimation]
            animationGroup.beginTime = CACurrentMediaTime() + animationDelay
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = 0
            animationGroup.fillMode = kCAFillModeForwards
            animationGroup.isRemovedOnCompletion = false;
            animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            _circularProgressLine?.add(animationGroup, forKey: "animationGroup")
            
            // I cannot get an update handler from the animation,
            // so the loop method will call the delegate instead
            startLoop()
        }
        
        if (newColor != nil) {
            lineColor = newColor!
        }
    }
    
    private func updateValueLabel(value: CGFloat, graphicsBounds: CGRect, scaleRatio: CGFloat, animated: Bool = true) {
        if (_valueLabelLayer == nil) {
            _valueLabelLayer = CACircularTextLayer()
            self.layer.addSublayer(_valueLabelLayer!)
        }
        
        _valueLabelLayer?.removeAllAnimations()
        
        if (!showValueLabel) {
            _valueLabelLayer?.textValue = ""
            _valueLabelLayer?.needsDisplay()
            return
        }
        
        _valueLabelLayer?.frame = graphicsBounds
        _valueLabelLayer?.radius = (graphicsBounds.width - lineWidth) / 2.0
        _valueLabelLayer?.textColor = labelColor
        _valueLabelLayer?.textSize = kReferenceFontSize * labelScale
        _valueLabelLayer?.endSpacing = roundEnds ? 0 : scaleRatio * kEndSpacing * CGFloat.pi
        _valueLabelLayer?.textValue = String(format: "%.0f", 100.0 * value) + "%"
        _valueLabelLayer?.allignedToEnd = true
        _valueLabelLayer?.angle = -value * 2.0 * CGFloat.pi + CGFloat.pi / 2.0
        _valueLabelLayer?.drawString()
        
        if (animated && animationDuration > 0 && progressValue > 0) {
            _valueLabelLayer?.opacity = 0.0
            
            let fadeInAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            fadeInAnimation.fromValue = 0.0
            fadeInAnimation.toValue = 1.0
            fadeInAnimation.beginTime = CACurrentMediaTime() + animationDelay + animationDuration / 2.0
            fadeInAnimation.duration = animationDuration / 2.0
            fadeInAnimation.repeatCount = 0
            fadeInAnimation.fillMode = kCAFillModeForwards
            fadeInAnimation.isRemovedOnCompletion = false
            fadeInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            _valueLabelLayer?.add(fadeInAnimation, forKey: "opacity")
            
            let rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = _valueLabelLayer!.angle - CGFloat.pi / 2.0
            rotationAnimation.toValue = 0.0
            rotationAnimation.beginTime = CACurrentMediaTime() + animationDelay
            rotationAnimation.duration = animationDuration
            rotationAnimation.repeatCount = 0
            rotationAnimation.fillMode = kCAFillModeForwards
            rotationAnimation.isRemovedOnCompletion = false
            rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            _valueLabelLayer?.add(rotationAnimation, forKey: "transform.rotation")
        }
    }
    
    private func updateNameLabel(value: CGFloat, graphicsBounds: CGRect, scaleRatio: CGFloat, animated: Bool = true) {
        if (_nameLabelLayer == nil) {
            _nameLabelLayer = CACircularTextLayer()
            self.layer.addSublayer(_nameLabelLayer!)
        }
        
        _nameLabelLayer?.removeAllAnimations()
        
        _nameLabelLayer?.frame = graphicsBounds
        _nameLabelLayer?.radius = (graphicsBounds.width - lineWidth) / 2.0
        _nameLabelLayer?.textColor = labelColor
        _nameLabelLayer?.textSize = kReferenceFontSize * labelScale
        _nameLabelLayer?.endSpacing = roundEnds ? 0 : scaleRatio * kEndSpacing * CGFloat.pi
        _nameLabelLayer?.textValue = name
        _nameLabelLayer?.angle = -(value * 2.0 * CGFloat.pi) + (CGFloat.pi / 2.0)
        _nameLabelLayer?.drawString()
        
        if (animated && animationDuration > 0 && progressValue > 0) {
            _nameLabelLayer?.opacity = 0.0
            
            let fadeInAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            fadeInAnimation.fromValue = 0.0
            fadeInAnimation.toValue = 1.0
            fadeInAnimation.beginTime = CACurrentMediaTime() + animationDelay + animationDuration / 2.0
            fadeInAnimation.duration = animationDuration / 2.0
            fadeInAnimation.repeatCount = 0
            fadeInAnimation.fillMode = kCAFillModeForwards
            fadeInAnimation.isRemovedOnCompletion = false
            fadeInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)            
            _nameLabelLayer?.add(fadeInAnimation, forKey: "opacity")
        }
    }
    
    private func startLoop() {
        if (_displayLink == nil) {
            _displayLink = CADisplayLink(target: self, selector: #selector(loop))
            _displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        }
        
        _displayLink!.isPaused = false
        
        let currentTime = Double(NSDate.timeIntervalSinceReferenceDate)
        _delayStartTime = animationDelay > 0 ? currentTime : 0.0
        _animationStartTime = animationDelay > 0 ? 0.0 : currentTime
    }
    
    private func stopLoop() {
        _delayStartTime = 0.0
        _animationStartTime = 0.0
        
        if (_displayLink != nil) {
            _displayLink!.isPaused = true
        }
    }
    
    func loop(displaylink: CADisplayLink) {
        let currentTime = Double(NSDate.timeIntervalSinceReferenceDate)
        
        if (_delayStartTime > 0) {
            if (_delayStartTime + animationDelay < currentTime) {
                _animationStartTime = currentTime
                _delayStartTime = 0
            } else {
                return
            }
        }
        
        if (_animationStartTime > 0) {
            if (_animationStartTime + animationDuration < currentTime) {
                stopLoop()
            } else {
                
                let ratio: Double = (currentTime - _animationStartTime) / animationDuration
                let eazedValue = getEazedValue(t: CGFloat(ratio))
                let lerpedValue = lerp(value: eazedValue, min: _oldProgressValue, max: progressValue)

                if (delegate != nil)
                {
                    delegate?.onCircularProgressValueUpdated(value: lerpedValue, index: index)
                }
            }
        }

    }

    public func lerp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if (min > max) {
            return max + ((1.0 - value) * (min - max))
        }
        
        return min + (value * (max - min))
    }

    public func getEazedValue(t: CGFloat) -> CGFloat {
        if t < 0.5 {
            return 4.0 * t * t * t
        } else {
            let f = t - 1.0
            return 1.0 + 4.0 * f * f * f
        }
    }

}
