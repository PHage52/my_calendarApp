//
//  CustomSegue.swift
//  scheduleApp+
//
//  Created by BCTRA on 2016/06/18.
//  Copyright © 2016年 AkikoHayashi. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    
    override func perform() {
        //遷移前のViewControllerのインスタンスを作成
        let calenderVC = self.sourceViewController.view as UIView!
        //遷移後のViewControllerのインスタンスを作成
        let eventAdd = self.destinationViewController.view as UIView!
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(eventAdd, aboveSubview: calenderVC)
        
        //画面の横の長さを取得
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        //画面の縦の長さを取得
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        //遷移後のビューを画面外(右側)にだしておく
        eventAdd.frame = CGRectMake(screenWidth, 0.0, screenWidth, screenHeight)
        
        //0.4秒で遷移する
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            //遷移前のビューを現在の位置から画面幅分移動する
            calenderVC.frame = CGRectOffset(calenderVC.frame, -screenWidth, 0.0)
            //遷移後のビューを現在の位置(画面外)から画面幅分移動する
            eventAdd.frame = CGRectOffset(eventAdd.frame, -screenWidth, 0.0)
        }) { (Finished) -> Void in
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,animated: false,completion: nil)
        }
    }

}
