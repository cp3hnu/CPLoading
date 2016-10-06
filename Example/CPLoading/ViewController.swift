//
//  ViewController.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/12.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var slider: UISlider!
    @IBOutlet var loadingView: CPLoadingView!
    var coefficient = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadingView.backgroundColor = UIColor.clear
        slider.value = Float(loadingView.lineWidth)
        loadingView.startLoading()
    }

    @IBAction func loading(_ sender: UIButton) {
        loadingView.startLoading()
    }
    
    @IBAction func setProgress(_ sender: UIButton) {
        let progress: Float = loadingView.progress + 0.1043
        loadingView.progress = progress
    }
    
    @IBAction func switchValueChanged(_ sender: AnyObject) {
        let switchCtr = sender as! UISwitch
        loadingView.hidesWhenCompleted = switchCtr.isOn
    }
    
    @IBAction func changeLineWith(_ sender: AnyObject) {
        if loadingView.status == .loading {
            let slider = sender as! UISlider
            loadingView.lineWidth = CGFloat(slider.value)
        } else {
            self.slider.value = Float(loadingView.lineWidth)
        }
    }
    
    @IBAction func stopLoadingWithSuccess(_ sender: UIButton) {
        loadingView.completeLoading(success: true)
    }
    
    @IBAction func stopLoadingWithFailure(_ sender: UIButton) {
        loadingView.completeLoading(success: false)
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        
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

