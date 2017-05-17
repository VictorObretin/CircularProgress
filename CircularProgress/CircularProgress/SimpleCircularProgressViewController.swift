//
//  SimpleCircularProgressViewController.swift
//  CircularProgress
//
//  Created by Victor Obretin on 2016-11-28.
//  Copyright © 2016 Victor Obretin. All rights reserved.
//

import UIKit

class SimpleCircularProgressViewController: PageItemViewController, CircularProgressViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var houseProgressView: UICircularProgressView!
    @IBOutlet weak var clothesProgressView: UICircularProgressView!
    @IBOutlet weak var commuteProgress: UICircularProgressView!
    @IBOutlet weak var groceriesProgressView: UICircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        containerView.frame = bounds
        
        resetViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        resetViews()
    }
    
    internal func resetViews() {
        houseProgressView.setProgressValue(value: 0, animated: false)
        clothesProgressView.setProgressValue(value: 0, animated: false)
        commuteProgress.setProgressValue(value: 0, animated: false)
        groceriesProgressView.setProgressValue(value: 0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        houseProgressView.setProgressValue(value: 0.90)
        clothesProgressView.setProgressValue(value: 0.70)
        commuteProgress.setProgressValue(value: 0.50)
        groceriesProgressView.setProgressValue(value: 0.30)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //or default
    }
    
    internal func onCircularProgressValueUpdated(value: CGFloat, index: Int) {
        
    }
    
    internal func onCircularProgressValueWillUpdate(value: CGFloat, index: Int) {
        
    }
}
