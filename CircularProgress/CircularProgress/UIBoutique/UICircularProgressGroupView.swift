//
//  UICircularProgressGroupController.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-12-02.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import Foundation

import UIKit

protocol CircularProgressGroupViewDelegate: class {
    func onCircularProgressGroupValueUpdated(value: CGFloat, groupIndex: Int, progressIndex: Int)
}

@IBDesignable
class UICircularProgressGroupView: UIView, CircularProgressViewDelegate {
    
    @IBInspectable var count: Int = 4
    @IBInspectable var lineWidth: CGFloat = 20
    @IBInspectable var spacing: CGFloat = 1
    @IBInspectable var scale: CGFloat = 1
    @IBInspectable var roundEnds: Bool = false
    @IBInspectable var animationDuration: Double = 1.5
    @IBInspectable var delayBetweenAnimations: Double = 0.2
    
    @IBInspectable var showValueLabel: Bool = true
    @IBInspectable var labelsColor: UIColor = UIColor.white
    @IBInspectable var labelScale: CGFloat = 1
    
    // Add more entries here as needed
    // Xcode doesn't support arrays as inspectable properties yet (all the other systems I worked with do)
    @IBInspectable var progressColor1: UIColor = UIColor.black
    @IBInspectable var progressLabel1: String = ""
    
    @IBInspectable var progressColor2: UIColor = UIColor.black
    @IBInspectable var progressLabel2: String = ""
    
    @IBInspectable var progressColor3: UIColor = UIColor.black
    @IBInspectable var progressLabel3: String = ""
    
    @IBInspectable var progressColor4: UIColor = UIColor.black
    @IBInspectable var progressLabel4: String = ""
    
    @IBInspectable var progressColor5: UIColor = UIColor.black
    @IBInspectable var progressLabel5: String = ""
    
    @IBInspectable var progressColor6: UIColor = UIColor.black
    @IBInspectable var progressLabel6: String = ""
    
    @IBInspectable var progressColor7: UIColor = UIColor.black
    @IBInspectable var progressLabel7: String = ""
    
    @IBInspectable var progressColor8: UIColor = UIColor.black
    @IBInspectable var progressLabel8: String = ""
    
    @IBInspectable var progressColor9: UIColor = UIColor.black
    @IBInspectable var progressLabel9: String = ""
    
    @IBInspectable var progressColor10: UIColor = UIColor.black
    @IBInspectable var progressLabel10: String = ""
    
    public var delegate: CircularProgressGroupViewDelegate?
    public var groupIndex: Int = 0
    
    private var _circularProgressViewsArray: Array<UICircularProgressView> = []
    private var _valuesArray: Array<CGFloat> = []
    private var _isAnimated: Bool = true
    
    private var _colorsArray: Array<UIColor> = []
    private var _labelsArray: Array<String> = []
    private var _loadEditorLabels: Bool = true
    
    private var _remainingDiameter: CGFloat = 0
    public var remainingDiameter: CGFloat {
        get {
            return _remainingDiameter
        }
    }
    
    func setValues(values: Array<CGFloat>, animated: Bool) {
        _isAnimated = animated
        _valuesArray = []
        _valuesArray.append(contentsOf: values)
        
        let elementsCount: Int = _circularProgressViewsArray.count
        let valuesCount: Int = values.count
        var delay:Double = 0.0
        
        for i in 0 ..< elementsCount {
            let circularProgressView: UICircularProgressView? = _circularProgressViewsArray[i]
            if (circularProgressView != nil) {
                circularProgressView?.animationDelay = delay
                delay += delayBetweenAnimations
                
                if (i < valuesCount) {
                    circularProgressView?.animationDuration = animated ? animationDuration : 0
                    circularProgressView?.setProgressValue(value: values[i])
                } else {
                    circularProgressView?.animationDuration = 0
                    circularProgressView?.setProgressValue(value: 0)
                }
                
            }
        }
    }
    
    func setLabels(labels: Array<String>) {
        _loadEditorLabels = false
        
        _labelsArray = []
        _labelsArray.append(contentsOf: labels)
        
        let elementsCount: Int = _circularProgressViewsArray.count
        let labelsCount: Int = labels.count
        
        for i in 0 ..< elementsCount {
            let circularProgressView: UICircularProgressView? = _circularProgressViewsArray[i]
            if (circularProgressView != nil) {
                circularProgressView?.name = i < labelsCount ? labels[i] : ""
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupComponent()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupComponent()
        
        let elementsCount: Int = _circularProgressViewsArray.count
        
        for i in 0 ..< elementsCount {
            let circularProgressView: UICircularProgressView? = _circularProgressViewsArray[i]
            if (circularProgressView != nil) {
                circularProgressView?.progressValue = 0.85
                circularProgressView?.prepareForInterfaceBuilder()
            }
        }
    }
    
    private func setupComponent() {
        _colorsArray = []
        _colorsArray.append(progressColor1)
        _colorsArray.append(progressColor2)
        _colorsArray.append(progressColor3)
        _colorsArray.append(progressColor4)
        _colorsArray.append(progressColor5)
        _colorsArray.append(progressColor6)
        _colorsArray.append(progressColor7)
        _colorsArray.append(progressColor8)
        _colorsArray.append(progressColor9)
        _colorsArray.append(progressColor10)
        // add extra colors here
        
        if (_loadEditorLabels)
        {
            _labelsArray = []
            _labelsArray.append(progressLabel1)
            _labelsArray.append(progressLabel2)
            _labelsArray.append(progressLabel3)
            _labelsArray.append(progressLabel4)
            _labelsArray.append(progressLabel5)
            _labelsArray.append(progressLabel6)
            _labelsArray.append(progressLabel7)
            _labelsArray.append(progressLabel8)
            _labelsArray.append(progressLabel9)
            _labelsArray.append(progressLabel10)
            // add extra label values here
        }
        
        while (count < _circularProgressViewsArray.count) {
            let circularProgressView: UICircularProgressView? = _circularProgressViewsArray.last
            if (circularProgressView != nil) {
                circularProgressView?.delegate = nil
                circularProgressView?.removeFromSuperview()
            }
            _circularProgressViewsArray.removeLast()
        }
        
        while (_circularProgressViewsArray.count < count) {
            let circularProgressView: UICircularProgressView = UICircularProgressView()
            circularProgressView.delegate = self
            self.addSubview(circularProgressView)
            _circularProgressViewsArray.append(circularProgressView)
        }
        
        let elementsCount: Int = _circularProgressViewsArray.count
        let totalLineWidth: CGFloat = (lineWidth + spacing) * scale
        var originX = self.bounds.origin.x
        var originY = self.bounds.origin.y
        _remainingDiameter = min(self.bounds.width, self.bounds.height)
        let colorsArrayCount: Int = _colorsArray.count
        let labelsCount: Int = _labelsArray.count
        
        for i in 0 ..< elementsCount {
            if (_remainingDiameter < 2 * totalLineWidth) {
                break
            }
            
            let circularProgressView: UICircularProgressView? = _circularProgressViewsArray[i]
            if (circularProgressView != nil) {
                circularProgressView?.lineWidth = lineWidth * scale
                circularProgressView?.showValueLabel = showValueLabel
                circularProgressView?.labelColor = labelsColor
                circularProgressView?.labelScale = labelScale * scale
                circularProgressView?.name = i < labelsCount ? _labelsArray[i] : ""
                circularProgressView?.index = i
                circularProgressView?.roundEnds = roundEnds
                
                originX = self.bounds.origin.x + (self.bounds.width - _remainingDiameter) / 2.0
                originY = self.bounds.origin.y + (self.bounds.height - _remainingDiameter) / 2.0
                
                let bounds: CGRect = CGRect(x: originX , y: originY, width: _remainingDiameter, height: _remainingDiameter)
                circularProgressView?.frame = bounds
                _remainingDiameter -= 2.0 * totalLineWidth
                
                circularProgressView?.lineColor = _colorsArray[i < colorsArrayCount ? i : colorsArrayCount - 1]
            }
        }
    }
    
    internal func onCircularProgressValueWillUpdate(value: CGFloat, index: Int) {
        
    }
    
    internal func onCircularProgressValueUpdated(value: CGFloat, index: Int) {
        if (delegate != nil) {
            delegate?.onCircularProgressGroupValueUpdated(value: value, groupIndex: groupIndex, progressIndex: index)
        }
    }
    
}
