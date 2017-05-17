//
//  CircularProgressGroupViewController.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-11-28.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import UIKit

class CircularProgressGroupViewController: PageItemViewController, CircularProgressGroupViewDelegate {

    @IBOutlet weak var circularProgressGroup: UICircularProgressGroupView!
    @IBOutlet weak var expensesContainerView: UIView!
    @IBOutlet weak var expensesTitleLabel: UILabel!
    @IBOutlet weak var expensesValueLabel: UILabel!
    
    var budgetValues: Array<CGFloat> = [1000.0, 1000.0, 1000.0, 1000.0]
    var progressBudgetValues: Array<CGFloat> = [1000.0, 1000.0, 1000.0, 1000.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        circularProgressGroup.delegate = self
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
        
        circularProgressGroup.frame = bounds
    }
    
    internal func resetViews() {
        progressBudgetValues = [0.0, 0.0, 0.0, 0.0]
        
        circularProgressGroup.setValues(values: [0, 0, 0, 0], animated: false)
        
        expensesValueLabel.text = "$0"
        
        circularProgressGroup.scale = min(circularProgressGroup.bounds.width, circularProgressGroup.bounds.height) / 320;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        circularProgressGroup.setValues(values: [0.85, 0.81, 0.78, 0.75], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //or default
    }

    func onCircularProgressGroupValueUpdated(value: CGFloat, groupIndex: Int, progressIndex: Int) {
        let elementsCount: Int = progressBudgetValues.count
        
        if (progressIndex >= budgetValues.count || progressIndex >= elementsCount) {
            return
        }
        
        progressBudgetValues[progressIndex] = value * budgetValues[progressIndex]
        
        var totalExpendedValue: CGFloat = 0.0
        for i in 0 ..< elementsCount {
            totalExpendedValue += progressBudgetValues[i]
        }
        
        expensesValueLabel.text = "$" + Int(ceil(totalExpendedValue)).description
        
        let expensesContainerX: CGFloat = (circularProgressGroup.bounds.width - circularProgressGroup.remainingDiameter) / 2.0
        let expensesContainerY: CGFloat = (circularProgressGroup.bounds.height - circularProgressGroup.remainingDiameter) / 2.0
        expensesContainerView.frame = CGRect(x: expensesContainerX, y: expensesContainerY, width: circularProgressGroup.remainingDiameter, height: circularProgressGroup.remainingDiameter)
        
        expensesTitleLabel.font = UIFont(descriptor: expensesTitleLabel.font.fontDescriptor, size: expensesTitleLabel.bounds.height)
        expensesValueLabel.font = UIFont(descriptor: expensesValueLabel.font.fontDescriptor, size: expensesValueLabel.bounds.height)
    }
}

