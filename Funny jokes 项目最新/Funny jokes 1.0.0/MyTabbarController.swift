//
//  MyTabbarController.swift
//  MyLocations
//
//  Created by Lxrent46 on 15/8/20.
//  Copyright © 2015年 zhihong. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController {
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        //设置tabbarcontroller的状态栏  字体为白色
        
        return  UIStatusBarStyle.LightContent
    }
    
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        //返回nil 忽略视图控制器所有状态栏的设置
        return nil
    }
    
    
    
    
    
}