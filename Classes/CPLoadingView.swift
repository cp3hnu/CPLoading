//
//  CPLoadingView.swift
//  CPLoading
//
//  Created by ZhaoWei on 15/10/12.
//  Copyright © 2015年 CSDEPT. All rights reserved.
//

import UIKit

let kCPRingStrokeAnimationKey = "CPLoadingView.stroke"
let kCPRingRotationAnimationKey = "CPLoadingView.rotation"
let kCPCompletionAnimationKey = "CPLoadingView.completion"
let kCPCompletionAnimationDuration: NSTimeInterval = 0.5
let kCPHidesWhenStoppedDelay: NSTimeInterval = 0.5

public typealias Block = () -> Void

public class CPLoadingView: UIView {
    
    @IBInspectable public var lineWidth: CGFloat = 1.0 {
        didSet {
            progressLayer.lineWidth = lineWidth
            shapeLayer.lineWidth = lineWidth
            
            setProgressLayerPath()
        }
    }
    
    @IBInspectable public var strokeColor: UIColor = UIColor(white: 0.0, alpha: 1.0) {
        didSet {
            progressLayer.strokeColor = strokeColor.CGColor
            shapeLayer.strokeColor = strokeColor.CGColor
        }
    }
    
    @IBInspectable public var hidesWhenStopped: Bool = false

    public private(set) var isLoading = false
    private let progressLayer: CAShapeLayer! = CAShapeLayer()
    private let shapeLayer: CAShapeLayer! = CAShapeLayer()
    
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
        
        let frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
        progressLayer.frame = frame
        shapeLayer.frame = frame
        
        setProgressLayerPath()
    }
    
    //MARK: - Public
    public func startLoading() {
        if isLoading {
            return
        }
        
        isLoading = true
        
        shapeLayer.hidden = true
        self.hidden = false
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 3.0
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.repeatCount = Float.infinity
        progressLayer.addAnimation(animation, forKey: kCPRingRotationAnimationKey)
        
        let totalDuration = 1.0
        let firstDuration = 0.6
        let secondDuration = totalDuration - firstDuration
        
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.duration = firstDuration
        headAnimation.fromValue = 0.0
        headAnimation.toValue = 0.25
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.beginTime = firstDuration
        endHeadAnimation.duration = secondDuration
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1.0
        
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.duration = firstDuration
        tailAnimation.fromValue = 0.0
        tailAnimation.toValue = 1.0
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.beginTime = firstDuration
        endTailAnimation.duration = secondDuration
        endTailAnimation.fromValue = 1.0
        endTailAnimation.toValue = 1.0
        
        let animations = CAAnimationGroup()
        animations.duration = totalDuration
        animations.repeatCount = Float.infinity
        animations.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        progressLayer.addAnimation(animations, forKey: kCPRingStrokeAnimationKey)
    }
    
    public func completeLoading(success: Bool, completion: Block? = nil) {
        if !isLoading {
            return
        }
        
        completionBlock = completion
        
        progressLayer.removeAnimationForKey(kCPRingRotationAnimationKey)
        progressLayer.removeAnimationForKey(kCPRingStrokeAnimationKey)
        
        progressLayer.strokeEnd = 1.0
        
        if success {
            setStrokeSuccessShapePath()
        } else {
            setStrokeFailureShapePath()
        }
        
        var strokeStart :CGFloat = 0.25
        var strokeEnd :CGFloat = 0.8
        
        if !success {
            let square = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
            let point = errorJoinPoint()
            let increase = 1.0/3 * square - point.x
            let sum = 2.0/3 * square
            strokeStart = increase / (sum + increase)
            strokeEnd = (increase + sum/2) / (sum + increase)
        }
        
        let duration = 0.7 * kCPCompletionAnimationDuration
        let increase = 0.3 * kCPCompletionAnimationDuration
        let timeFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.shapeLayer.strokeEnd = 1.0
        self.shapeLayer.strokeStart = strokeStart
        let headStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        headStartAnimation.fromValue = 0.0
        headStartAnimation.toValue = 0.0
        headStartAnimation.duration = duration
        headStartAnimation.timingFunction = timeFunction
        
        let headEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        headEndAnimation.fromValue = 0.0
        headEndAnimation.toValue = strokeEnd
        headEndAnimation.duration = duration
        headEndAnimation.timingFunction = timeFunction
        
        let tailStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        tailStartAnimation.fromValue = 0.0
        tailStartAnimation.toValue = strokeStart
        tailStartAnimation.beginTime = duration
        tailStartAnimation.duration = increase
        tailStartAnimation.timingFunction = timeFunction
        
        let tailEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailEndAnimation.fromValue = strokeEnd
        tailEndAnimation.toValue = 1.0
        tailEndAnimation.beginTime = duration
        tailEndAnimation.duration = increase
        tailEndAnimation.timingFunction = timeFunction
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [headEndAnimation, headStartAnimation, tailStartAnimation, tailEndAnimation]
        groupAnimation.duration = duration + increase
        groupAnimation.delegate = self
        self.shapeLayer.addAnimation(groupAnimation, forKey: kCPCompletionAnimationKey)
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if hidesWhenStopped {
            NSTimer.scheduledTimerWithTimeInterval(kCPHidesWhenStoppedDelay, target: self, selector: "hiddenLoadingView", userInfo: nil, repeats: false)
        } else {
            isLoading = false
            if completionBlock != nil {
                completionBlock!()
            }
        }
    }
    
    //MARK: - Private
    private func initialize() {
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
        progressLayer.strokeEnd = 1.0
    }
    
    private func setStrokeSuccessShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        let b = square/2
        let oneTenth = square/10
        let xOffset = oneTenth
        let yOffset = 1.5 * oneTenth
        let ySpace = 3.2 * oneTenth
        let point = correctJoinPoint()
        
        //y1 = x1 + xOffset + yOffset
        //y2 = -x2 + 2b - xOffset + yOffset
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, point.x, point.y)
        CGPathAddLineToPoint(path, nil, b - xOffset, b + yOffset)
        CGPathAddLineToPoint(path, nil, 2 * b - xOffset + yOffset - ySpace, ySpace)
        
        shapeLayer.path = path
        shapeLayer.cornerRadius = square/2
        shapeLayer.masksToBounds = true
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
        self.shapeLayer.hidden = false
    }
    
    private func setStrokeFailureShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        let b = square/2
        let space = square/3
        let point = errorJoinPoint()
    
        //y1 = x1
        //y2 = -x2 + 2b
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, point.x, point.y)
        CGPathAddLineToPoint(path, nil, 2 * b - space, 2 * b - space)
        CGPathMoveToPoint(path, nil, 2 * b - space, space)
        CGPathAddLineToPoint(path, nil, space, 2 * b - space)
       
        shapeLayer.path = path
        shapeLayer.cornerRadius = square/2
        shapeLayer.masksToBounds = true
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.0
        shapeLayer.hidden = false
    }
    
    private func correctJoinPoint() -> CGPoint {
        let r = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2
        let m = r/2
        let k = lineWidth/2
    
        let a: CGFloat = 2.0
        let b = -4 * r + 2 * m
        let c = (r - m) * (r - m) + 2 * r * k - k * k
        let x = (-b - sqrt(b * b - 4 * a * c))/(2 * a)
        let y = x + m
    
        return CGPointMake(x, y)
    }
    
    private func errorJoinPoint() -> CGPoint {
        let r = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2
        let k = lineWidth/2
    
        let a :CGFloat = 2.0
        let b = -4 * r
        let c = r * r + 2 * r * k - k * k
        let x = (-b - sqrt(b * b - 4 * a * c))/(2 * a)
    
        return CGPointMake(x, x)
    }
    
    private func stopLoading() {
        if !isLoading {
            return
        }
        isLoading = false
        
        progressLayer.removeAnimationForKey(kCPRingRotationAnimationKey)
        progressLayer.removeAnimationForKey(kCPRingStrokeAnimationKey)
    }

    @objc private func resetAnimations() {
        if isLoading {
            stopLoading()
            startLoading()
        }
    }
    
    @objc private func hiddenLoadingView() {
        isLoading = false
        
        self.hidden = true
        shapeLayer.hidden = true
        
        if completionBlock != nil {
            completionBlock!()
        }
    }
}

