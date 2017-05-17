//
//  CircularProgressWithLabelViewController.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-11-28.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import UIKit

class CircularProgressWithLabelViewController: PageItemViewController, CircularProgressViewDelegate {
    
    @IBOutlet weak var budgetProgressView: UICircularProgressView!
    @IBOutlet weak var budgetLabel: UILabel!
    
    private var originalLineColor: UIColor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        budgetProgressView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetViews()
    }
    
    override func viewDidLayoutSubviews() {
        var bounds:CGRect = self.view.bounds
        let minSize:CGFloat = min(bounds.size.width, bounds.size.height) - 40
        
        bounds.origin.x = (self.view.bounds.size.width - minSize) / 2.0
        bounds.origin.y = (self.view.bounds.size.height - minSize) / 2.0
        bounds.size.width = minSize
        bounds.size.height = minSize
        
        budgetProgressView.frame = bounds
        
        resetViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        resetViews()
    }
    
    internal func resetViews() {        
        if (originalLineColor == nil) {
            originalLineColor = budgetProgressView.lineColor
        }
        
        budgetProgressView.setProgressValue(value: 0.8, animated: false, newColor: originalLineColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let yellowColor: UIColor = UIColor.init(red: 254/255,   green: 208/255,     blue: 77/255,   alpha: 1.0)
        budgetProgressView.setProgressValue(value: 0.3, animated: true, newColor: yellowColor)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //or default
    }
    
    func onCircularProgressValueWillUpdate(value: CGFloat, index: Int) {
        
    }
    
    func onCircularProgressValueUpdated(value: CGFloat, index: Int) {
        let budgetValue: CGFloat = value * 8500.0
        budgetLabel.text = "$" + Int(ceil(budgetValue)).description
    }
}
