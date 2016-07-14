//
//  TableViewController.swift
//  ScheduleApp
//
//  Created by BCTRA on 2016/05/29.
//  Copyright © 2016年 BCTRA. All rights reserved.
//
import UIKit

/* 日付を表示 */
class CustomCell: UICollectionViewCell {
    
    //セルの要素
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
