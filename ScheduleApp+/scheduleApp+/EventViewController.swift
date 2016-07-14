//
//  EventViewController.swift
//  scheduleApp+
//
//  Created by BCTRA on 2016/06/20.
//  Copyright © 2016年 AkikoHayashi. All rights reserved.
//

import UIKit
import EventKit

var editevent: EKEvent?

class EventViewController: UITableViewController {

    //選択日のイベントを格納する配列
    struct DayEvent {
        
        var name: String = ""
        var start: NSDate
        var end: NSDate
        var allday: Bool
        var id: String
    }
    
    var dayEvent = [DayEvent]()
    
    @IBOutlet weak var MddLabel: UILabel!
    
    let dateManager = DateManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //EventStoreの初期化
        myEventStore = EKEventStore()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面が表示される直前に実行される
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //ラベルを変更
        MddLabel.text = dateManager.monthDayLabel(selectedDate)
        
        //テーブルビューと配列をリロード
        self.tableView.reloadData()
        dayEvent.removeAll()
        //イベントを探す
        serchEvent()
        
    }
    
    //テーブルビューにアイテム表示
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("eventcell") as! TableViewCell
        
        if (!dayEvent.isEmpty) {
        
            cell.eventLabel.text = dayEvent[indexPath.row].name
        
            //時間のフォーマット
            let formatStart = dateManager.dayHourLabel(dayEvent[indexPath.row].start)
            let formatEnd = dateManager.dayHourLabel(dayEvent[indexPath.row].end)
        
            //イベントの時間表示
            if (dayEvent[indexPath.row].allday != true) {
                cell.dayLabel.text = "開始：\(formatStart) 終了：\(formatEnd)"
            } else {
                cell.dayLabel.text = "終日"
            }
        }
        
        return cell
    }
    
    
    
    // セルの行数をカウントするメソッド
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayEvent.count
    }
    
    //表示月から選択日のイベントを探すメソッド
    func serchEvent(){
        
        //デフォルトカレンダー指定
        let defaultCalendar = myEventStore.defaultCalendarForNewEvents
        //選択日から24時間以内のイベント
        let selectEnd = NSDate(timeInterval: 60*60*24, sinceDate: selectedDate)
        // 検索するためのクエリー的なものを用意
        let predicate = myEventStore.predicateForEventsWithStartDate(selectedDate, endDate: selectEnd, calendars: [defaultCalendar])
        // イベントを検索
        let events = myEventStore.eventsMatchingPredicate(predicate)
        
        for i in events {
            //イベント内容を構造体に格納
            dayEvent.append(DayEvent(name: i.title, start: i.startDate, end: i.endDate, allday: i.allDay, id: i.eventIdentifier))
        }
        
    }
    

    
    
    //スライドで削除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            //スライドされたセルのイベントデータを取得
            editevent = myEventStore.eventWithIdentifier(dayEvent[indexPath.row].id)
            
            // イベントをカレンダーにセット
            editevent!.calendar = myEventStore.defaultCalendarForNewEvents
            
            do {
                //イベント削除
                try myEventStore.removeEvent(editevent!, span: .ThisEvent)
            } catch let error {
                print(error)
            }
            
            //日付イベント配列からイベントを削除
            print(dayEvent[indexPath.row].name, "を削除しました")
            
            dayEvent.removeAtIndex(indexPath.row)
            
            
            tableView.reloadData()
        }
    }
    
    //セルが選択された時のメソッド
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        //選択状態であるフラグ
        editflag = true
        //選択されたセルのイベントデータを取得
        editevent = myEventStore.eventWithIdentifier(dayEvent[indexPath.row].id)
        
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
