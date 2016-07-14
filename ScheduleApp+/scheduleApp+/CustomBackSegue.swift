//
//  CustomBackSegue.swift
//  scheduleApp+
//
//  Created by BCTRA on 2016/06/19.
//  Copyright © 2016年 AkikoHayashi. All rights reserved.
//

import UIKit

class CustomBackSegue: UIStoryboardSegue {
    
    override func perform() {
        //遷移前のViewControllerのインスタンスを作成
        let eventAdd = self.sourceViewController.view as UIView!
        //遷移後のViewControllerのインスタンスを作成
        let calenderVC = self.destinationViewController.view as UIView!
        
        //画面の横の長さを取得
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        //画面の縦の長さを取得
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        //遷移後のビューを画面外(左側)にだしておく
        calenderVC.frame = CGRectMake(-screenWidth, 0.0, screenWidth, screenHeight)
        
        //戻った先のビューを現在の画面の上にのせる
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(calenderVC, aboveSubview: eventAdd)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            //現在のビューを画面外に移動させる。
            eventAdd.frame = CGRectOffset(eventAdd.frame, screenWidth, 0.0)
            //戻った先のビューを画面上に移動させる。
            calenderVC.frame = CGRectOffset(calenderVC.frame, screenWidth, 0.0)
            
        }) { (Finished) -> Void in
            //現在の画面を閉じる
            self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }


}
