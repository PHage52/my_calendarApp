//
//  TableViewController.swift
//  ScheduleApp
//
//  Created by BCTRA on 2016/05/29.
//  Copyright © 2016年 BCTRA. All rights reserved.
//

import UIKit
import EventKit

//イベント開始日
var starteventDate = NSDate()

//編集時のフラグ
var editflag:Bool = false

//EventStoreの初期化
var myEventStore: EKEventStore!

class TableViewController: UITableViewController, UITextFieldDelegate {
    
    //アウトレット
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endText: UITextField!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var alldaySwitch: UISwitch!
    //通知スイッチ
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    //メンバ変数
    var toolBar:UIToolbar!
    let Date = NSDate()
    let startPickerView:UIDatePicker = UIDatePicker()
    let endPickerView:UIDatePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    //終日設定時のフォーマット
    let dateFM: String = "MM月dd日"
    //終日設定ではないときのフォーマット
    let datetimeFM: String = "MM月dd日 (E) HH:mm"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //EventStoreの初期化
        myEventStore = EKEventStore()
        
        // selfをデリゲートにする
        nameText.delegate = self
        
        dateFormatter.dateFormat  = dateFM;
        
        //終日スイッチが押された時の処理
        alldaySwitch.addTarget(self, action: #selector(TableViewController.onClickAlldaySwicth(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        
        
        //開始セルが選択されたときDatePickerViewを表示
        startPickerView.datePickerMode = UIDatePickerMode.Date
        startPickerView.timeZone = NSTimeZone.systemTimeZone()
        startPickerView.locale = NSLocale(localeIdentifier: "ja_JP")
        startText.inputView = startPickerView
        startPickerView.addTarget(self, action: #selector(TableViewController.startPickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //終了セルが選択されたときDatePickerViewを表示
        endPickerView.datePickerMode = UIDatePickerMode.Date
        endPickerView.timeZone = NSTimeZone.systemTimeZone()
        endPickerView.locale = NSLocale(localeIdentifier: "ja_JP")
        endText.inputView = endPickerView
        endPickerView.addTarget(self, action: #selector(TableViewController.endPickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        //DatePicker上のToolBarの完了ボタン
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarBtn = UIBarButtonItem(title: "完了", style: .Plain, target: self, action: #selector(TableViewController.doneBtn))
        toolBar.items = [toolBarBtn]
        startText.inputAccessoryView = toolBar
        endText.inputAccessoryView = toolBar
        
        // 認証確認
        allowAuthorization()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func allowAuthorization() {
        print("allowAuthorized")
        
        // ステータスを取得
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        if status != EKAuthorizationStatus.Authorized {
            // ユーザーに許可を求める
            myEventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
                (granted , error) -> Void in
                
                // 許可を得られなかった場合アラート発動
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御 非同期
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // アラート生成
                        let myAlert = UIAlertController(title: "許可されませんでした",
                            message: "Privacy->App->Reminderで変更してください",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // アラートアクション
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
    //画面が表示される直前に実行される
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (editflag == false) {
            
            //初期状態で開始と終了に選択されたカレンダーの日付を表示
            startLabel.text = dateFormatter.stringFromDate(selectedDate)
            endLabel.text = dateFormatter.stringFromDate(selectedDate)
            
            //DatePickerの値も変更
            startPickerView.date = selectedDate
            endPickerView.date = selectedDate
            
        } else {
            
            //セルを選択して開いたとき選択されたイベントの情報を表示
            nameText.text = editevent?.title
            
            //終日かどうかの処理
            if (editevent?.allDay == true) {
                alldaySwitch.on = true
                dateFormatter.dateFormat = dateFM
                startLabel.text = dateFormatter.stringFromDate((editevent?.startDate)!)
                endLabel.text = dateFormatter.stringFromDate((editevent?.endDate)!)
                startPickerView.datePickerMode = UIDatePickerMode.Date
                endPickerView.datePickerMode = UIDatePickerMode.Date
            }
            else {
                alldaySwitch.on = false
                startPickerView.datePickerMode = UIDatePickerMode.DateAndTime
                endPickerView.datePickerMode = UIDatePickerMode.DateAndTime
                dateFormatter.dateFormat = datetimeFM
                startLabel.text = dateFormatter.stringFromDate((editevent?.startDate)!)
                endLabel.text = dateFormatter.stringFromDate((editevent?.endDate)!)
            }
            
            
            if (editevent?.alarms != nil) {
                
                alarmSwitch.on = true
            } else {
                alarmSwitch.on = false
            }
            
            
            
            //DatePickerの値も変更
            startPickerView.date = (editevent?.startDate)!
            endPickerView.date = (editevent?.endDate)!
        }
        
    }
    
    //終日設定スイッチが押されたときの処理
    internal func onClickAlldaySwicth(sender: UISwitch) -> Bool{ ///MySwicthをAlldaySwitchに変更
        //フォーマットの変更
        if sender.on {
            startPickerView.datePickerMode = UIDatePickerMode.Date
            endPickerView.datePickerMode = UIDatePickerMode.Date
            dateFormatter.dateFormat = dateFM
            startLabel.text = dateFormatter.stringFromDate(selectedDate)
            endLabel.text = dateFormatter.stringFromDate(selectedDate)
            return true
        } else {
            startPickerView.datePickerMode = UIDatePickerMode.DateAndTime
            endPickerView.datePickerMode = UIDatePickerMode.DateAndTime
            dateFormatter.dateFormat = datetimeFM
            startLabel.text = dateFormatter.stringFromDate(selectedDate)
            endLabel.text = dateFormatter.stringFromDate(selectedDate)
            return false
        }
    }
    
    

    //開始のDatePickerが選択されたら開始ラベルに表示
    func startPickerValueChanged(sender:UIDatePicker) {
        
        startLabel.text = dateFormatter.stringFromDate(sender.date)
    }
    
    //終了のDatePickerが選択されたら終了ラベルに表示
    func endPickerValueChanged(sender:UIDatePicker) {
        
        endLabel.text = dateFormatter.stringFromDate(sender.date)
    }
    
    //ToolBarの完了ボタン
    func doneBtn(){
        startText.resignFirstResponder()
        endText.resignFirstResponder()
        startPickerValueChanged(startPickerView)
        endPickerValueChanged(endPickerView)
    }

    //テキストフィールドにデータが追加されたかどうかの処理
    private func isValidateInputContents() -> Bool{
        // 名前の入力
        if let name = nameText.text{
            if name.characters.count == 0{
                return false
            }
        }else{
            return false
        }
        return true
    }
    
    //ユーザがキーボード以外の場所をタップするとキーボードを閉じる
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    //returnが押されたときキーボードを閉じる処理
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        return true
    }
    
    
    //キャンセルボタンの処理
    @IBAction func cancel(sender: UIButton) {
        
        
        editflag = false
    }
    
    //セーブボタンの処理
    @IBAction func save(sender: UIButton) {
        // 入力チェック
        if isValidateInputContents() == false{
            let myAlert = UIAlertController(title: "イベント名を入力してください", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAlertAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return
        }
        
        print("setMyPlanToCalendar")
        
        // イベントを作成して情報をセット
        let startDate = startPickerView.date
        let endDate = endPickerView.date
        
        //イベント情報を作成
        let myEvent = EKEvent(eventStore: myEventStore)
  
        myEvent.title = nameText.text!
        myEvent.startDate = startDate
        myEvent.endDate = endDate
        
        // 終日かどうか
        myEvent.allDay = onClickAlldaySwicth(alldaySwitch)
        
        //通知スイッチの処理
        if (alarmSwitch.on == true) {
            let alarm:EKAlarm = EKAlarm(relativeOffset: -600)
            myEvent.alarms = [alarm]
        }
        
        
        // イベントをカレンダーにセット
        myEvent.calendar = myEventStore.defaultCalendarForNewEvents
        
        
        do {
            //イベント保存
            try myEventStore.saveEvent(myEvent, span: .ThisEvent)
            
            //編集状態であったとき元のイベントを削除
            if (editflag == true) {
                do{
                    try myEventStore.removeEvent(editevent!, span: .ThisEvent)
                } catch let error {
                    print(error)
                }
            }
            
            //保存完了メッセージ
            let myAlert = UIAlertController(title: "保存に成功しました", message: "イベント名 :\(nameText.text!)", preferredStyle: UIAlertControllerStyle.Alert)
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAlertAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        } catch let error {
            print(error)
            //エラーメッセージ
            let myAlert = UIAlertController(title: "保存に失敗しました", message: (nameText.text), preferredStyle: UIAlertControllerStyle.Alert)
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAlertAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
        
        //アプリカレンダーに保存
        myCalendar()
        editflag = false
        
        
    }
    
    //標準時刻との時差を計算し調整する
    func myCalendar() -> (start: NSDate, end: NSDate, startlabel : NSDate, endlabel: NSDate){
        
        let myCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let startcomps = myCalendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: startPickerView.date)
        let endcomps = myCalendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: endPickerView.date)
        
        //時差を考慮した現在時刻
        let nowDate = NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT))
        print("標準時刻",Date)
        print("ローカル時刻",nowDate)
        
        //時差計算
        let Dif = nowDate.timeIntervalSinceDate(Date)
        print(Dif)
        let intDif: Int = Int(Dif)
        print(intDif)
        
        //NSdate型に変換
        let startGMT = myCalendar.dateWithEra(1, year: startcomps.year, month: startcomps.month, day: startcomps.day, hour: startcomps.hour, minute: startcomps.minute, second: 0, nanosecond: 0)!
        let startLOC = myCalendar.dateByAddingUnit(.Second, value: intDif, toDate: startGMT, options: NSCalendarOptions())!
        print("start日付変換",startLOC)
        
        let endGMT = myCalendar.dateWithEra(1, year: endcomps.year, month: endcomps.month, day: endcomps.day, hour: endcomps.hour, minute: endcomps.minute, second: 0, nanosecond: 0)!
        let endLOC = myCalendar.dateByAddingUnit(.Second, value: intDif, toDate: endGMT, options: NSCalendarOptions())!
        print("end日付変換",endLOC)
        
        starteventDate = startLOC
        print("カレンダーに開始日保存", starteventDate)
        
        return (startGMT, endGMT, startLOC, endLOC)

    }
    

    

    
}
/*
 //標準時刻との時差を計算し調整する
 func myCalender() -> (start: NSDate, end: NSDate, startlabel : NSDate, endlabel: NSDate){
 
 let myCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
 let startcomps = myCalendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: startPickerView.date)
 let endcomps = myCalendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: endPickerView.date)
 
 //時差を考慮した現在時刻
 let nowDate = NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT))
 print("標準時刻",Date)
 print("ローカル時刻",nowDate)
 
 //時差計算
 let Dif = nowDate.timeIntervalSinceDate(Date)
 print(Dif)
 let intDif: Int = Int(Dif)
 print(intDif)
 
 //NSdate型に変換
 let startGMT = myCalendar.dateWithEra(1, year: startcomps.year, month: startcomps.month, day: startcomps.day, hour: startcomps.hour, minute: startcomps.minute, second: 0, nanosecond: 0)!
 let startLOC = myCalendar.dateByAddingUnit(.Second, value: intDif, toDate: startGMT, options: NSCalendarOptions())!
 print("start日付変換",startLOC)
 
 let endGMT = myCalendar.dateWithEra(1, year: endcomps.year, month: endcomps.month, day: endcomps.day, hour: endcomps.hour, minute: endcomps.minute, second: 0, nanosecond: 0)!
 let endLOC = myCalendar.dateByAddingUnit(.Second, value: intDif, toDate: endGMT, options: NSCalendarOptions())!
 print("end日付変換",endLOC)
 
 return (startGMT, endGMT, startLOC, endLOC)
 
 }
 */

