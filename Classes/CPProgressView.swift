//
//  CPProgressView.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/21.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import Foundation
import UIKit

let kCPPCompletionAnimationDuration: NSTimeInterval = 0.3
let kCPPHidesWhenCompletedDelay: NSTimeInterval = 2.3

public class CPProgressView : UIView {
    
    public enum ProgressStatus: Int {
        case Loading, Progress, Completion
    }
    
    @IBInspectable public var lineWidth: CGFloat = 1.0 {
        didSet {
            progressLayer.lineWidth = lineWidth
            shapeLayer.lineWidth = lineWidth
            
            setProgressLayerPath()
        }
    }
    
    @IBInspectable public var strokeColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0) {
        didSet {
            progressLayer.strokeColor = strokeColor.CGColor
            shapeLayer.strokeColor = strokeColor.CGColor
            progressLabel.textColor = strokeColor
        }
    }
    
    @IBInspectable public var fontSize: Float = 30 {
        didSet {
            progressLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        }
    }
    
    @IBInspectable public var hidesWhenCompleted: Bool = false
    
    public var hidesAfterTime: NSTimeInterval = kCPPHidesWhenCompletedDelay
    
    public private(set) var status: ProgressStatus = .Completion
    
    private var _progress: Float = 0.0
    public var progress: Float {
        get {
            return _progress
        }
        set(newProgress) {
            if status == .Loading {
                progressLayer.removeAllAnimations()
            } else if status == .Completion {
                shapeLayer.strokeStart = 0
                shapeLayer.strokeEnd = 0
                shapeLayer.removeAllAnimations()
            }
            status = .Progress
            
            _progress = min(max(0, newProgress), 1)
            progressLayer.strokeEnd = CGFloat(_progress)
            
            progressLabel.hidden = false
            progressLabel.text = "\(Int(_progress * 100))"
        }
    }
    
    private let progressLayer: CAShapeLayer! = CAShapeLayer()
    private let shapeLayer: CAShapeLayer! = CAShapeLayer()
    private let progressLabel: UILabel! = UILabel()
    
    private var completionBlock: Block?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        
        let bounds = CGRectMake(0, 0, square, square)
        
        progressLayer.frame = CGRectMake(0, 0, width, height)
        setProgressLayerPath()
        
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        
        let labelSquare = sqrt(2) / 2.0 * square
        progressLabel.bounds = CGRectMake(0, 0, labelSquare, labelSquare)
        progressLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    }
    
    //MARK: - Public
    public func startLoading() {
        if status == .Loading {
            return
        }
        
        status = .Loading
        
        progressLabel.hidden = true
        progressLabel.text = "0"
        _progress = 0
        
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.removeAllAnimations()
        
        self.hidden = false
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 4.0
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.repeatCount = Float.infinity
        progressLayer.addAnimation(animation, forKey: kCPRingRotationAnimationKey)
        
        let totalDuration = 1.0
        let firstDuration = 2.0 * totalDuration / 3.0
        let secondDuration = totalDuration / 3.0
        
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.duration = firstDuration
        headAnimation.fromValue = 0.0
        headAnimation.toValue = 0.25
        
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.duration = firstDuration
        tailAnimation.fromValue = 0.0
        tailAnimation.toValue = 1.0
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.beginTime = firstDuration
        endHeadAnimation.duration = secondDuration
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1.0
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.beginTime = firstDuration
        endTailAnimation.duration = secondDuration
        endTailAnimation.fromValue = 1.0
        endTailAnimation.toValue = 1.0
        
        let animations = CAAnimationGroup()
        animations.duration = firstDuration + secondDuration
        animations.repeatCount = Float.infinity
        animations.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        progressLayer.addAnimation(animations, forKey: kCPRingStrokeAnimationKey)
    }
    
    public func completeLoading(success: Bool, completion: Block? = nil) {
        if status == .Completion {
            return
        }
        
        if status == .Loading {
            progressLayer.removeAllAnimations()
        }
        
        progressLabel.hidden = true
        
        completionBlock = completion
        
        let progressFromStrokeEnd = progressLayer.strokeEnd
        var progressToStrokeEnd: CGFloat = 0.0
        
        if success {
            progressToStrokeEnd = 1.0
            setStrokeSuccessShapePath()
        } else {
            setStrokeFailureShapePath()
        }
        
        shapeLayer.strokeEnd = 1.0
        let timeFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let shapeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shapeAnimation.fromValue = 0.0
        shapeAnimation.toValue = 1.0
        shapeAnimation.duration = kCPPCompletionAnimationDuration
        shapeAnimation.timingFunction = timeFunction
        shapeAnimation.delegate = self
        shapeLayer.addAnimation(shapeAnimation, forKey: nil)
        
        progressLayer.strokeEnd = progressToStrokeEnd
        
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.fromValue = progressFromStrokeEnd
        progressAnimation.toValue = progressToStrokeEnd
        progressAnimation.duration = kCPPCompletionAnimationDuration
        progressAnimation.timingFunction = timeFunction
        progressLayer.addAnimation(progressAnimation, forKey: nil)
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if hidesWhenCompleted {
            NSTimer.scheduledTimerWithTimeInterval(kCPPHidesWhenCompletedDelay, target: self, selector: "hiddenLoadingView", userInfo: nil, repeats: false)
        } else {
            status = .Completion
            if completionBlock != nil {
                completionBlock!()
            }
        }
    }
    
    
    //MARK: - Private
    private func initialize() {
        //progressLabel
//        progressLabel.font = UIFont.systemFontOfSize(16)
//        progressLabel.foregroundColor = UIColor.blackColor().CGColor
//        progressLabel.alignmentMode = kCAAlignmentCenter
//        progressLabel.backgroundColor = UIColor.redColor().CGColor
//        self.layer.addSublayer(progressLabel)
        
        progressLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        progressLabel.textColor = strokeColor
        progressLabel.textAlignment = .Center
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.hidden = true
        self.addSubview(progressLabel)
        
        
        //progressLayer
        progressLayer.strokeColor = strokeColor.CGColor
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        self.layer.addSublayer(progressLayer)
        
        //shapeLayer
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
        self.layer.addSublayer(shapeLayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"resetAnimations", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func setProgressLayerPath() {
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let radius = (min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) - progressLayer.lineWidth) / 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        progressLayer.path = path.CGPath
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
    }
    
    private func setStrokeSuccessShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height);
        let b = square/2;
        let oneTenth = square/10;
        let xOffset = oneTenth;
        let yOffset = 1.5 * oneTenth;
        let xSpace = 2.5 * oneTenth;
        let ySpace = 3.2 * oneTenth;
        
        //y1 = x1 + xOffset + yOffset;
        //y2 = -x2 + 2b - xOffset + yOffset;
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, xSpace, xSpace + xOffset + yOffset);
        CGPathAddLineToPoint(path, nil, b - xOffset, b + yOffset);
        CGPathAddLineToPoint(path, nil, 2 * b - xOffset + yOffset - ySpace, ySpace);
        
        shapeLayer.path = path;
        shapeLayer.strokeStart = 0.0;
        shapeLayer.strokeEnd = 0.0;
        shapeLayer.hidden = false;
    }
    
    private func setStrokeFailureShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height);
        let b = square/2;
        let space = square/3;
        
        //y1 = -x1 + 2b;
        //y2 = x2;
        let path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 2 * b - space, space);
        CGPathAddLineToPoint(path, nil, space, 2 * b - space);
        CGPathMoveToPoint(path, nil, space, space);
        CGPathAddLineToPoint(path, nil, 2 * b - space, 2 * b - space);
        
        shapeLayer.path = path;
        shapeLayer.strokeStart = 0.0;
        shapeLayer.strokeEnd = 0.0;
        shapeLayer.hidden = false
    }
    
    @objc private func resetAnimations() {
        if status == .Loading {
            status = .Completion
            progressLayer.removeAnimationForKey(kCPRingRotationAnimationKey)
            progressLayer.removeAnimationForKey(kCPRingStrokeAnimationKey)
            
            startLoading()
        }
    }
    
    @objc private func hiddenLoadingView() {
        status = .Progress
        self.hidden = true

        if completionBlock != nil {
            completionBlock!()
        }
    }
}