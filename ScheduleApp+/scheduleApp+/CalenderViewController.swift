//
//  ViewController.swift
//  ScheduleApp
//
//  Created by BCTRA on 2016/05/11.
//  Copyright © 2016年 BCTRA. All rights reserved.
//
import UIKit
import EventKit

//月ごとのイベントを格納する配列
struct MonthEvent {
    
    var name: String = ""
    var date: String = ""
    var start: NSDate
    var end: NSDate
    var allday: Bool
}

var monthEvent = [MonthEvent]()

//表示月取得用
var selectedMonth = NSDate()
//選択された日付
var selectedDate = NSDate()
//セルのtag保存用
var cellTag = [Int]()


class CalenderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let dateManager = DateManager()
    let cellMargin: CGFloat = 0.3
    var today = NSDate()
    let weekArray = ["日", "月", "火", "水", "木", "金", "土"]
    let yearMonthLabelHeight: CGFloat = 60
    var myEventStore: EKEventStore!
    //選択された日付番号
    var selectDayindex = Int()
    
    
    //アウトレット
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var yearMonthLabel: UILabel!
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //EventStoreの初期化
        myEventStore = EKEventStore()
        
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        
        //カレンダー背景色
        calenderCollectionView.backgroundColor = UIColor.lightGray()
        
        yearMonthLabel.text = dateManager.yearMonthLabel(today)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //NSDate -> String
    class func stringFromDate(date: NSDate, format: String) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
    
    //カレンダーの描画
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("daycell", forIndexPath: indexPath) as! CustomCell
        
        //セル背景色
        cell.backgroundColor = UIColor.whiteColor()
        //セルのラベル非表示
        cell.eventLabel.text = ""
        
        //セルを選択できるようにする
        cell.userInteractionEnabled = true
        
        
        //文字色
        if (indexPath.row % 7 == 0) {
            
            //日曜日は赤
            cell.dayLabel.textColor = UIColor.lightRed()
            
        } else if (indexPath.row % 7 == 6) {
            
            //土曜日は青
            cell.dayLabel.textColor = UIColor.lightBlue()
            
        } else {
            
            //平日は黒
            cell.dayLabel.textColor = UIColor.blackColor()
        }
        
        //曜日・日付文字
        if (indexPath.section == 0) {
            //日付表示
            cell.dayLabel.text = weekArray[indexPath.row]
            
            //曜日をタップしたときの背景色(セルと同じ色)
            cell.selectedBackgroundView = dateManager.cellSelectedBackgroundView(UIColor.whiteColor())
            
            //曜日枠線
            dateManager.border(cell, borderWidth: 1.0, borderColor: UIColor.whiteColor().CGColor)
            
        } else {
            
            cell.dayLabel.text = dateManager.conversionDateFormat(indexPath)
            cell.tag = Int (dateManager.conversionDateFormat(indexPath))!
            
            cellTag += [cell.tag]
            //print(cellDay[indexPath.row])
            
            //indexPathをyyyy-MM-ddへ変換
            let yyyyMMddIndexPath = dateManager.nsIndexPathformatYYYYMMDD(indexPath)
            
            //今日の年月日をyyyy-MM-ddへ変換
            let yyyyMMddToday = dateManager.formatYYYYMMDD(today)
            
            //表示月をMMへ変換
            let mmSelectedDate = dateManager.formatMM(selectedMonth)
            
            //indexPathをMMへ変換
            let mmIndexPath = dateManager.nsIndexPathformatMM(indexPath)
            
            
            //表示月の中にイベントが存在するかどうか
            for j in 0..<monthEvent.count  {
                if (yyyyMMddIndexPath == monthEvent[j].date) {
                    cell.eventLabel.text = monthEvent[j].name
                }
            }
            
            
            if (yyyyMMddIndexPath == yyyyMMddToday) {
                
                //今日の枠線
                dateManager.border(cell, borderWidth: 2.0, borderColor: UIColor.brownColor().CGColor)
                
            } else {
                
                //今日以外の枠線
                dateManager.border(cell, borderWidth: 1.0, borderColor: UIColor.whiteColor().CGColor)
            }
            
            //前月・次月日付背景色を設定
            if (((mmSelectedDate - 1) == mmIndexPath) ||
                ((mmSelectedDate + 1) == mmIndexPath) ||
                (mmSelectedDate == 12 && mmIndexPath == 1) ||
                (mmSelectedDate == 1 && mmIndexPath == 12)) {
                

                if (yyyyMMddIndexPath == yyyyMMddToday) {
                    
                    //枠線をクリア
                    dateManager.border(cell, borderWidth: 1.0, borderColor: UIColor.whiteColor().CGColor)
                }
                
                //背景色をグレー
                cell.backgroundColor = UIColor.WhiteGray()
                //セルを選択できなくする
                cell.userInteractionEnabled = false
            }
            
            //日付をタップしたときの背景色
            cell.selectedBackgroundView = dateManager.cellSelectedBackgroundView(UIColor.lightGreen())
            
        }
        
        return cell
    }
    
    //セクション０：曜日　セクション１：日付
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // 表示するセルの数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            // 曜日表示は７つ
            return 7
        } else {
            // 日付表示は月によって変わる
            dateManager.daysAcquisition()
            dateManager.dateForCellAtIndexPath()
            return dateManager.numberOfItems
        }
    }
    
    //１つのセルサイズ
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let width: CGFloat = floor(collectionView.frame.size.width / 7)
        let widthRest = collectionView.frame.size.width - (width * 7)
        var height: CGFloat!
        let section0Height: CGFloat = width * 0.5
        
        if indexPath.section == 0 {
            
            height = section0Height
            
        } else {
            
            if (CGFloat(indexPath.row / 7 + 1) == dateManager.dayOfMonthLineNumber()) {
                
                height = dateManager.oneHeightSizePlus(collectionView.frame.size.height, section0Height: section0Height)
            }
            
            height = dateManager.oneHeightSize(collectionView.frame.size.height, section0Height: section0Height)
            
        }
        
        //横幅設定
        if (indexPath.row == 6) || (indexPath.row == 12) ||
            (indexPath.row == 18) || (indexPath.row == 24) ||
            (indexPath.row == 30) || (indexPath.row == 36) {
            
            return CGSizeMake(width + widthRest, height)
            
        } else {
            
            return CGSizeMake(width, height)
        }
    }
    
    //セルの左右マージン
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    //セルの上下マージン
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    //セクションのマージン
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(0.0, 0.0, 1.0, 0.0);
        } else {
            return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        }
    }
    
    //選択されたセルの日付番号を取得
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //セルから取得したタグを日付として変数に格納
        selectDayindex = cellTag[indexPath.row]

        selectDateMake()
    }
    
    //取得した日付番号から日付データに変換
    func selectDateMake() -> NSDate{
        
        let myCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let selectcomps = myCalendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: selectedMonth)
        
        //月を表示月、日付を選択日付としてNSdate型に変換
        selectedDate = myCalendar.dateWithEra(1, year: selectcomps.year, month: selectcomps.month, day: selectDayindex, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        
        return selectedDate
        
    }
    
    
    //月末を取得する
    func endOfMonth(date:NSDate) -> (Monthday: Int, Selectday: Int)
    {
        let cal = NSCalendar.currentCalendar()
        let flags : NSCalendarUnit = [.Year, .Month, .Day]
        let comps : NSDateComponents = cal.components(flags , fromDate: date)
        
        var y = comps.year
        var m = comps.month
        m = m + 1
        if (m >= 13) {
            y = y + 1
            m = 1
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd";
        
        let firstOfMonth : NSDate = dateFormatter.dateFromString("\(y)-\(m)-01")!
        
        let endOfMonth : NSDate = firstOfMonth.dateByAddingTimeInterval(-60*60*24)
        
        let monthend : NSDateComponents = cal.components(flags , fromDate: endOfMonth)
        
        return (monthend.day, comps.day)
    }
    
    //保存されたイベントを取得する
    func eventView() {
        
        
        //選択日から月の頭までと月末までの期間
        let endSpan = endOfMonth(selectedMonth).Monthday - endOfMonth(selectedMonth).Selectday
        
        let startSpan = endOfMonth(selectedMonth).Selectday - 1
        
        
        //カレンダー生成
        let myCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        // ユーザのカレンダーを取得
        let myEventCalendars = myEventStore.defaultCalendarForNewEvents
        
        // 開始日(月の頭)コンポーネントの生成
        let oneMonthAgoComponents: NSDateComponents = NSDateComponents()
        oneMonthAgoComponents.day = -startSpan
        
        // 月の頭から今日までのNSDateを生成
        let oneMonthAgo = myCalendar.dateByAddingUnit(.Day, value: -startSpan, toDate: selectedMonth, options: NSCalendarOptions())!
        
        // 終了日(次月)コンポーネントの生成
        let oneMonthfromNowComponents: NSDateComponents = NSDateComponents();oneMonthfromNowComponents.day = endSpan
        
        // 今日から月末までのNSDateを生成
        let oneMonthfromNow = myCalendar.dateByAddingUnit(.Day, value: endSpan, toDate: selectedMonth, options: NSCalendarOptions())!
        
        // イベントストアのインスタンスメソッドで述語を生成
        var predicate = NSPredicate()
        
        // 検索するためのクエリー的なものを用意
        predicate = myEventStore.predicateForEventsWithStartDate(oneMonthAgo, endDate: oneMonthfromNow, calendars: [myEventCalendars])
        
        // イベントを検索
        let events = myEventStore.eventsMatchingPredicate(predicate)

        // イベントが見つかった場合
        if !events.isEmpty {
            for i in events {
                
                //フォーマットを指定
                let formatDate = dateManager.formatYYYYMMDD(i.startDate)
                
                
                //月のイベントを構造体に格納
                monthEvent.append(MonthEvent(name: i.title, date: formatDate, start: i.startDate, end: i.endDate, allday: i.allDay))
            
            }
        }
    }
    
    //画面変遷から戻った後
    @IBAction func unwindToSubject(segue:UIStoryboardSegue){
        
        selectedDate = NSDate()
        //表示する月は今月
        selectedMonth = dateManager.thisMonth(selectedMonth)
        relodeEvent()
        
    }
    
    
    //右にスワイプで前の月を表示
    @IBAction func prevSwipe(sender: UISwipeGestureRecognizer) {
        //選択月変更
        selectedMonth = dateManager.prevMonth(selectedMonth)
        
        relodeEvent()
        
        yearMonthLabel.text = dateManager.yearMonthLabel(selectedMonth)
        
    }
    
    //左にスワイプで次の月を表示
    @IBAction func nextSwipe(sender: UISwipeGestureRecognizer) {
        //選択月変更
        selectedMonth = dateManager.nextMonth(selectedMonth)
        
        relodeEvent()
        
        yearMonthLabel.text = dateManager.yearMonthLabel(selectedMonth)
    }

    //今日のボタンが押されたら今月に戻す
    @IBAction func todayBtn(sender: AnyObject) {
        //表示する月は今月
        selectedMonth = dateManager.thisMonth(today)
        
        relodeEvent()
        
        yearMonthLabel.text = dateManager.yearMonthLabel(selectedMonth)
    }
    
    //バックグラウンドになったとき
    func enterBackground(notification: NSNotification){
        //表示する月は今月
        selectedMonth = dateManager.thisMonth(today)
        
        relodeEvent()

        yearMonthLabel.text = dateManager.yearMonthLabel(selectedMonth)
    }
    
    //フォアグラウンドになったとき
    func enterForeground(notification: NSNotification){
        
    }
    
    //画面が表示される直前に実行される
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        relodeEvent()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalenderViewController.enterBackground(_:)), name:"applicationDidEnterBackground", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalenderViewController.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
    }
    
    //別の画面に遷移する直前に実行される
    override func viewWillDisappear(animated: Bool) {
        
        relodeEvent()
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "applicationDidEnterBackground", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "applicationWillEnterForeground", object: nil)
    }
    
    //イベントの配列の更新を行う
    func relodeEvent() {
        //月の取得イベント、取得タグをリセット
        monthEvent.removeAll()
        cellTag.removeAll()
        //新しくイベント読み込み
        eventView()
        //カレンダーの更新
        calenderCollectionView.reloadData()
    }
    
}













