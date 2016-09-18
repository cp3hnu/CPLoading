//
//  UsageViewController.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/26.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

class UsageViewController: UIViewController, URLSessionDownloadDelegate {

    @IBOutlet var loadingView: CPLoadingView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var requestButton: UIButton!
    
    var dataSession: Foundation.URLSession!
    var downloadSession: Foundation.URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.backgroundColor = UIColor.clear
        loadingView.strokeColor = UIColor.white
        loadingView.hidesWhenCompleted = true
        
        imageView.backgroundColor = UIColor.black
        
        resetButton.isEnabled = false
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        dataSession = Foundation.URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        downloadSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        dataSession.invalidateAndCancel()
        downloadSession.invalidateAndCancel()
    }
    
    //MARK: Button Action
    @IBAction func requestImage(_ sender: UIButton) {
        
        requestButton.isEnabled = false
        downloadButton.isEnabled = false
        
        loadingView.startLoading()
        
        let url = URL(string: "http://imgsrc.baidu.com/forum/pic/item/a71ea8d3fd1f4134854c9235251f95cad1c85e05.jpg")
        
        let dataTask = dataSession.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            if let imageData = data , error == nil {
                let image = UIImage(data: imageData)
                self.imageView.image = image
                self.loadingView.completeLoading(true)
            } else {
                self.loadingView.completeLoading(false)
            }
            
            self.resetButton.isEnabled = true
        }) 
        
        dataTask.resume()
    }
    
    @IBAction func downloadImage(_ sender: UIButton) {
        
        requestButton.isEnabled = false
        downloadButton.isEnabled = false
        
        loadingView.startLoading()
    
        let url = URL(string: "http://img2.niutuku.com/desk/1208/1400/ntk-1400-9953.jpg")
        
        let downloadTask = downloadSession.downloadTask(with: url!)
        downloadTask.resume()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
        imageView.image = nil
        self.requestButton.isEnabled = true
        self.downloadButton.isEnabled = true
        self.resetButton.isEnabled = false
    }
    
    //MARK: Delegate
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
        loadingView.progress = Float(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = try? Data(contentsOf: location)
        if let imageData = data {
            let image = UIImage(data: imageData)
            imageView.image = image
        }
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            loadingView.completeLoading(true)
        } else {
            loadingView.completeLoading(false)
        }
        
        self.resetButton.isEnabled = true
    }
}
