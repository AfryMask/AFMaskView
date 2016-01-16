//
//  ViewController.swift
//  AFMaskView
//
//  Created by Afry on 16/1/16.
//  Copyright © 2016年 AfryMasker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置基本信息
        let screenSize = UIScreen.mainScreen().bounds.size
        let maskViewFrame = CGRectMake(0, screenSize.height/2 - 100, screenSize.width, 200)
        let maskViewImageName = "thanks"
        let targetPoints = [CGPointMake(94, 90), CGPointMake(160, 90), CGPointMake(220, 90), CGPointMake(280, 90)]
        
        // 初始化，并添加到view中
        let maskView = AFView(frame: maskViewFrame, imageName:maskViewImageName, points:targetPoints)
        self.view.addSubview(maskView)
        
    }


}

