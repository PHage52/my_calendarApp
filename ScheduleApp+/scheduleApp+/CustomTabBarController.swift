//
//  CustomTabBarController.swift
//  scheduleApp+
//
//  Created by BCTRA on 2016/06/30.
//  Copyright © 2016年 AkikoHayashi. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fontの設定
        let fontFamily: UIFont! = UIFont.systemFontOfSize(10)
        
        // 選択時の設定
        let selectedColor:UIColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1)
        let selectedAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName:selectedColor]
        /// タイトルテキストカラーの設定
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, forState: UIControlState.Selected)
        /// アイコンカラーの設定
        UITabBar.appearance().tintColor = selectedColor
        
        
        // 非選択時の設定
        let nomalAttributes = [NSFontAttributeName: fontFamily, NSForegroundColorAttributeName: UIColor.whiteColor()]
        /// タイトルテキストカラーの設定
        UITabBarItem.appearance().setTitleTextAttributes(nomalAttributes, forState: UIControlState.Normal)
        /// アイコンカラー（画像）の設定
        var assets :Array<String> = ["Schedule.png", "money.png", "pen.png"]
        for (idx, item) in self.tabBar.items!.enumerate() {
            item.image = UIImage(named: assets[idx])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
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
