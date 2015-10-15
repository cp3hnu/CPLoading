//
//  ViewController.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/12.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var loadingView: CPLoadingView!
    var coefficient = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadingView.backgroundColor = UIColor.clearColor()
        loadingView.startLoading()
    }

    @IBAction func Loading(sender: UIButton) {
        loadingView.startLoading()
    }
    
    @IBAction func SwitchValueChanged(sender: AnyObject) {
        let switchCtr = sender as! UISwitch
        loadingView.hidesWhenStopped = switchCtr.on
    }
    
    @IBAction func ChangeLineWith(sender: AnyObject) {
        guard loadingView.isLoading else { return }
        let slider = sender as! UISlider
        loadingView.lineWidth = CGFloat(slider.value)
    }
    
    @IBAction func stopLoadingWithSuccess(sender: UIButton) {
        loadingView.completeLoading(true)
    }
    
    @IBAction func stopLoadingWithFailure(sender: UIButton) {
        loadingView.completeLoading(false)
    }
    
    @IBAction func changeColor(sender: UIButton) {
        
        let red = arc4random()%256
        let green = arc4random()%256
        let blue = arc4random()%256
        
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        
        loadingView.strokeColor = color
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
