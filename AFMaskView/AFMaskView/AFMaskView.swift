//
//  AFMaskView.swift
//  AFMaskView
//
//  Created by Afry on 16/1/16.
//  Copyright © 2016年 AfryMasker. All rights reserved.
//

import UIKit

// 向遮罩view传入的的图片
var dynamicMaskViewColor: UIColor?
// 目标点的数组
var targetPoints: [CGPoint]?
// 目标点是否已被扫过的数组
var targetPointMarks: [Bool]?

class AFView: UIView {
    
    
    /**
     禁用原生init
     */
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    /**
     初始化方法
     */
    init(frame: CGRect, imageName: String, points: [CGPoint]) {
        super.init(frame: frame)
        
        // 初始化
        targetPoints = points
        targetPointMarks = [Bool]()
        for _ in targetPoints! {
            targetPointMarks!.append(false)
        }
        
        // 背景view，缩放
        let image = UIImage(named: imageName)
        UIGraphicsBeginImageContext(frame.size)
        image!.drawInRect(self.bounds)
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backgroundColor = UIColor(patternImage: resizeImage)
        
        // 初始MaskView
        dynamicMaskView = AFMaskView(frame: self.bounds)
        dynamicMaskView!.backgroundColor = UIColor.clearColor()
        addSubview(dynamicMaskView!)
        dynamicMaskViewColor = UIColor(patternImage: resizeImage.applyLightEffect())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"finishDrag", name: "finishDrag", object: nil)
    }
    
    
    /**
     重置dynamicMaskView
     */
    func finishDrag() {
        
        // 清空所有路径
        self.dynamicMaskView!.path = UIBezierPath()
        self.dynamicMaskView!.paths = [UIBezierPath]()
        
        targetPointMarks = [Bool]()
        for _ in targetPoints! {
            targetPointMarks!.append(false)
        }
        
        self.dynamicMaskView!.setNeedsDisplay()
        
    }
    
    var dynamicMaskView: AFMaskView?
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    
}

/**
 遮罩View
 */
class AFMaskView: UIView {
    
    // 当前点，线，线s
    var p: CGPoint = CGPointZero
    var path: UIBezierPath?
    var paths: [UIBezierPath] = [UIBezierPath]()
    
    
    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // 毛玻璃图片绘制
        CGContextSetFillColorWithColor(ctx, dynamicMaskViewColor!.CGColor)
        CGContextAddRect(ctx, self.frame)
        CGContextFillPath(ctx)
        
        
        // 文字绘制
        CGContextSetBlendMode(ctx, CGBlendMode.Normal);
        let str = "试试手气吧" as NSString
        str.drawInRect(CGRectMake(self.bounds.width/2-50, self.bounds.height/2+40,100,30) , withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(20)])

        
        // 当前线条和历史线条绘制
        CGContextSetBlendMode(ctx, CGBlendMode.Clear);
        
        if p != CGPointZero {
            path!.lineJoinStyle = .Round
            path!.lineCapStyle = .Round
            path!.lineWidth = 20;
            
            path!.stroke()
        }
        
        if paths.count != 0 {
            for oldpath in paths {
                
                oldpath.lineJoinStyle = .Round
                oldpath.lineCapStyle = .Round
                oldpath.lineWidth = 20;
                
                oldpath.stroke()
            }
        }
        
//        // 设置画线模式
//        CGContextSetBlendMode(ctx, CGBlendMode.Normal);
//        
//        // 显示需要经过的点(可省略)
//        for point in targetPoints!{
//            
//            let reachPath = UIBezierPath()
//            reachPath.moveToPoint(point)
//            reachPath.addLineToPoint(CGPointMake(point.x+10, point.y))
//            reachPath.addLineToPoint(CGPointMake(point.x+10, point.y+10))
//            reachPath.addLineToPoint(CGPointMake(point.x, point.y+10))
//            reachPath.closePath()
//            UIColor.redColor().setFill()
//            reachPath.fill()
//            
//        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        p = touch!.locationInView(self)
        
        path = UIBezierPath()
        path!.moveToPoint(p)
        path!.addLineToPoint(p)
        self.setNeedsDisplay()
        
        // 判断是否到达某点
        for (idx, point) in targetPoints!.enumerate(){
            if abs(point.x - p.x)<20 && abs(point.y - p.y)<20 && !targetPointMarks![idx]{
                targetPointMarks![idx] = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        p = touch!.locationInView(self)
        
        path?.addLineToPoint(p)
        self.setNeedsDisplay()
        
        // 判断是否到达某点
        for (idx, point) in targetPoints!.enumerate(){
            // 减少计算量，但是降低精确度的做法
            if abs(point.x - p.x)<20 && abs(point.y - p.y)<20 && !targetPointMarks![idx]{
                targetPointMarks![idx] = true
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        p = touch!.locationInView(self)
        
        path?.addLineToPoint(p)
        paths.append(path!)
        
        // 判断是否完成寻点
        self.setNeedsDisplay()
        
        finishDrag()
    }
    
    
    // 完成寻点
    func finishDrag(){
        
        for (idx, _) in targetPoints!.enumerate(){
            if !targetPointMarks![idx]{
                return
            }
        }
        
        let alert = UIAlertController(title: "Message", message: "你永远都抽不到,略略略", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            
            NSNotificationCenter.defaultCenter().postNotificationName("finishDrag", object: nil, userInfo: nil)
        }))
        window!.rootViewController!.presentViewController(alert, animated: true) { () -> Void in
            
        }
        
    }
    
}