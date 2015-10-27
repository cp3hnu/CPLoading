//
//  UsageViewController.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/26.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

class UsageViewController: UIViewController, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate {

    @IBOutlet var loadingView: CPLoadingView!
    @IBOutlet var imageView: UIImageView!
    var data: NSMutableData = NSMutableData()
    
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var requestButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.backgroundColor = UIColor.clearColor()
        loadingView.strokeColor = UIColor.whiteColor()
        loadingView.hidesWhenCompleted = true
        
        imageView.backgroundColor = UIColor.blackColor()
        
        resetButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Action
    @IBAction func requestImage(sender: UIButton) {
        
        requestButton.enabled = false
        downloadButton.enabled = false
        
        loadingView.startLoading()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let url = NSURL(string: "http://imgsrc.baidu.com/forum/pic/item/a71ea8d3fd1f4134854c9235251f95cad1c85e05.jpg")
        
        let dataTask = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if let imageData = data where error == nil {
                let image = UIImage(data: imageData)
                self.imageView.image = image
                self.loadingView.completeLoading(true)
            } else {
                self.loadingView.completeLoading(false)
            }
            
            self.resetButton.enabled = true
        }
        
        dataTask.resume()
    }
    
    @IBAction func downloadImage(sender: UIButton) {
        
        requestButton.enabled = false
        downloadButton.enabled = false
        
        loadingView.startLoading()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let url = NSURL(string: "http://img2.niutuku.com/desk/1208/1400/ntk-1400-9953.jpg")
        
        let downloadTask = session.downloadTaskWithURL(url!)
        downloadTask.resume()
    }
    
    @IBAction func reset(sender: UIButton) {
        
        imageView.image = nil
        self.requestButton.enabled = true
        self.downloadButton.enabled = true
        self.resetButton.enabled = false
    }
    
    //MARK: Delegate
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
        loadingView.progress = Float(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)
        if let imageData = data {
            let image = UIImage(data: imageData)
            imageView.image = image
        }
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if error == nil {
            loadingView.completeLoading(true)
        } else {
            loadingView.completeLoading(false)
        }
        
        self.resetButton.enabled = true
    }
}
