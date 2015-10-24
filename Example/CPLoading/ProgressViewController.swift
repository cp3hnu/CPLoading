//
//  ProgressViewController.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/21.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet var progressView: CPProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //progressView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func HidesWhenCompletion(sender: UISwitch) {
        progressView.hidesWhenCompleted = sender.on
    }

    @IBAction func ChangeLineWidth(sender: UISlider) {
        progressView.lineWidth = CGFloat(sender.value)
    }
    
    @IBAction func ChangeStrokeColor(sender: UIButton) {
        let red = arc4random()%256
        let green = arc4random()%256
        let blue = arc4random()%256
        
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        
        progressView.strokeColor = color
    }
    
    @IBAction func ChangeUnderColor(sender: UIButton) {
        let red = arc4random()%256
        let green = arc4random()%256
        let blue = arc4random()%256
        
        _ = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    
    }
    
    @IBAction func Loading(sender: UIButton) {
        progressView.startLoading()
    }
    
    @IBAction func SetProgress(sender: UIButton) {
        let progress: Float = progressView.progress + 0.1
        progressView.progress = progress
    }
    
    
    @IBAction func CompleteSuccessfully(sender: UIButton) {
        progressView.completeLoading(true)
    }
    
    @IBAction func CompleteUnsuccessfully(sender: UIButton) {
        progressView.completeLoading(false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
