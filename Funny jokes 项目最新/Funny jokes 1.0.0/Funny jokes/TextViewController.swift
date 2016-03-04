//
//  TextTableViewController.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit
import CoreData

let formatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyyMMddHHmmss"
    return formatter
    }()

class TextViewController: UIViewController, MoreTableViewControllerDelegate, UIGestureRecognizerDelegate, TextCellDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var hassearched = false
    var hasResults = false
    var currentPage = 1
    var flag = 0
    
    var textJokeS = [GeneralJoke]()
    var tempJokeS = [GeneralJoke]()
    var generalJokeS = [GeneralJoke]()

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIStatusBarStyle.LightContent

        let nibtextJokeCell = UINib(nibName: "TextCell", bundle: nil)
        tableView.registerNib(nibtextJokeCell, forCellReuseIdentifier: "textJokeCell")
        
//     手势划
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeRecognizer.delegate = self
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        tableView.addGestureRecognizer(swipeRecognizer)

        let fetch = NSFetchRequest(entityName: "GeneralJoke")
        fetch.predicate = NSPredicate(format: "jokeType = %@", "Text")
        
        
        do {
            generalJokeS = [GeneralJoke]()
            generalJokeS = try managedObjectContext.executeFetchRequest(fetch) as! [GeneralJoke]
            
        } catch {
            fatalError()
        }
        
        for generalJoke in generalJokeS {
            textJokeS.append(generalJoke)
        }
        
        self.textJokeS.sortInPlace({ (r1, r2) -> Bool in
            return r1.create_time!.localizedStandardCompare(r2.create_time!) == NSComparisonResult.OrderedDescending
        })
        tableView.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "refresh")
        tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "footReFresh")
        
        getDataFromInternet(29, page: 1)

    }
    
    func swipeLeft() {
        let VCs = self.tabBarController?.viewControllers
        let vc = VCs![1]
        self.tabBarController?.selectedViewController = vc
  
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if textJokeS.count == 0 {
            tableView.header.beginRefreshing()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        figerOutNetworkOfType()
        
    }
    
    func figerOutNetworkOfType() {
        let statusType = IJReachability.isConnectedToNetworkOfType()
        switch statusType {
        case .WWAN:
            print("Connection Type: Mobile")
            let alert = UIAlertController(title: "您正在使用流量上网,请你注意", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(Action)
            presentViewController(alert, animated: true, completion: nil)
        case .WiFi:
            print("Connection Type: WiFi")
            if textJokeS.count == 0 {
                getDataFromInternet(29, page: 1)
            }
            
        case .NotConnected:
            let alert = UIAlertController(title: "无法连接到网络，请检查您的网络", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let Action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
                if self.tableView.header.isRefreshing() {
                    self.tableView.header.endRefreshing()
                }
            })
            
            alert.addAction(Action)
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        let aaa = deviceWidth
        deviceWidth = self.view.bounds.width
        if deviceWidth != aaa {
            tableView.reloadData()
        }
        
    }
    
    func removeAllAndReLoadData(controller: MoreTableViewController) {
        textJokeS.removeAll()
        generalJokeS.removeAll()
        if tableView != nil {
            tableView.reloadData()
        }
        
    }
    
    func justReloadData(controller: MoreTableViewController) {
        if tableView != nil {
            tableView.reloadData()
        }
    }
    
    func showAlert(textCell: TextCell, text: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let sendToFriendAction = UIAlertAction(title: "分享到朋友圈", style: UIAlertActionStyle.Default) { (_) -> Void in
            //分享朋友圈
            let message:WXMediaMessage = WXMediaMessage()
            let ext:WXWebpageObject = WXWebpageObject();
            message.mediaObject = ext
            
            let req = SendMessageToWXReq()
            req.scene = 1
            req.text = text + "\r" + "来自 - FunnyJoke"
            req.bText = true
            req.message = message
            WXApi.sendReq(req)
        }
        
        let sendToFriendSAction = UIAlertAction(title: "分享给好友", style: UIAlertActionStyle.Default) { (_) -> Void in
            
            let message:WXMediaMessage = WXMediaMessage()
            let ext:WXWebpageObject = WXWebpageObject();
            message.mediaObject = ext
            
            let req = SendMessageToWXReq()
            req.scene = Int32(WXSceneSession.rawValue)
            req.text = text + "\r" + "来自 - FunnyJoke"
            req.bText = true
            req.message = message
            WXApi.sendReq(req)
            
        }
        
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(sendToFriendAction)
        alert.addAction(sendToFriendSAction)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func footReFresh() {
        getDataFromInternet(29, page: ++currentPage)
    }
    
    func refresh() {
        getDataFromInternet(29, page: 1)
    }
    
    @IBAction func refreshBTnChecked(sender: UIBarButtonItem) {
        tableView.header.beginRefreshing()
    }
    
    
    
    
    func getDataFromInternet(type: Int, page: Int) {
        
        
        hassearched = true
        
        hasResults = true

            let time = formatter.stringFromDate(NSDate())
        
            let urlString = String(format: "https://route.showapi.com/255-1?page=%@&showapi_appid=8439&showapi_timestamp=%@&title=&type=%@&showapi_sign=5e90925cb0694ac9bde874a19025bc17","\(page)",time, "\(type)")

            let url = NSURL(string: urlString)
            
            let request = NSMutableURLRequest(URL: url! , cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
            request.HTTPMethod = "GET"
        
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                var dictionary: [String: AnyObject]?
                if let error = error {
                    print("error = \(error)")
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            
                            dictionary = self.parerJSON(data!)
                            
                        }else {
                            print("responder..\(httpResponse)")
                        }
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if let dictionary = dictionary {

                        let showapi_res_body = dictionary["showapi_res_body"] as! [String: AnyObject]
                        if let pagebean = showapi_res_body["pagebean"] as? [String: AnyObject] {
                            if pagebean["contentlist"] != nil {
                                self.getResultFromJSONDictionary(dictionary)
                                
                                self.textJokeS.appendContentsOf(self.tempJokeS)
                                
                                self.textJokeS.sortInPlace({ (r1, r2) -> Bool in
                                    return r1.create_time!.localizedStandardCompare(r2.create_time!) == NSComparisonResult.OrderedDescending
                                })
                                
                                self.savejokesToCoreData()
                                self.tableView.reloadData()
                                
                            } else {
                                print("数据获取失败，请重新搜索")
                                
                            }
                        } else {
                            print("数据获取失败，请重新搜索")
                            
                        }
                        
                    } else {
                        print("数据获取失败，请重新搜索")
                        
                    }

                    if self.tableView.header.isRefreshing() {
                        self.tableView.header.endRefreshing()
                    }
                    if self.tableView.footer.isRefreshing() {
                        self.tableView.footer.endRefreshing()
                    }
                    
                    })
                
                })
        
            dataTask.resume()
        

        }
    
    func parerJSON(data: NSData) -> [String: AnyObject]? {
        
        // NSdata类型变为 字典
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
            let resultDictionary = jsonResult as! [String: AnyObject]
            return resultDictionary
        }
        catch {
            getDataFromInternet(29, page: ++currentPage)
        }
        
        return nil
    }
    
    func savejokesToCoreData() {

        do {
            try managedObjectContext.save()
        } catch {
            fatalError()
        }

    }
    
    func getResultFromJSONDictionary(jsonDictionary: [String: AnyObject]) {
        
        
        
        let showapi_res_body = jsonDictionary["showapi_res_body"] as! [String: AnyObject]
        let pagebean = showapi_res_body["pagebean"] as! [String: AnyObject]
        
//        let allNum = pagebean["allNum"] as! Int
//        let allPages = pagebean["allPages"] as! Int
        
        currentPage = pagebean["currentPage"] as! Int
        let contentlist = pagebean["contentlist"] as! [[String: AnyObject]]
        
        var jokesHadSave: [GeneralJoke]
        let fetch = NSFetchRequest(entityName: "GeneralJoke")
        fetch.predicate = NSPredicate(format: "jokeType = %@", "Text")
        do {
            jokesHadSave = try managedObjectContext.executeFetchRequest(fetch) as! [GeneralJoke]
        } catch {
            fatalError()
        }
        
        tempJokeS.removeAll()
        
        for result in contentlist {

            var a = 0
            let id = result["id"] as? String
            
            for one in jokesHadSave {
                if one.id == id {
                    a = 1
                    break
                }
            }
            
            if a == 1 {
                a = 0
                continue
            }
            
            let onejoke = NSEntityDescription.insertNewObjectForEntityForName("GeneralJoke", inManagedObjectContext: managedObjectContext) as! GeneralJoke

            
            onejoke.jokeType = "Text"
            onejoke.text = result["text"] as? String
            onejoke.create_time = result["create_time"] as? String
            onejoke.hate = result["hate"] as? String
            onejoke.love = result["love"] as? String
            onejoke.name = result["name"] as? String
            onejoke.profile_image = result["profile_image"] as? String
            onejoke.weixin_url = result["weixin_url"] as? String
            onejoke.id = result["id"] as? String
            
            
            if let profile_image = onejoke.profile_image {
                downloadPicture(profile_image, pictureID: onejoke.id!)
            }
            
            tempJokeS.append(onejoke)
            
            
        }
        
    }
    
    
    func downloadPicture(profile_image: String,pictureID: String) {
        
        let profileURL = NSURL(string: profile_image)
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(profileURL!, completionHandler: { (data, responder, error) -> Void in
            if let error = error {
                print("error: \(error)")
            } else {
                if let httpHeader = responder as? NSHTTPURLResponse {
                    
                    if httpHeader.statusCode == 200 {
                        
                        self.savePicture(data!, pictureID: pictureID)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                        })
                        
                    } else {
                        print("responder: \(responder)")
                    }
                }
                
            }
        })

        dataTask.resume()
    }
    
    func savePicture(data: NSData, pictureID: String) {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let path = paths[0]+"/alljokes/"+pictureID+".png"
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return
        }
        
        do {
            try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)

            
        } catch {
            fatalError()
        }
        
        
        
    }

}


extension TextViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return textJokeS.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 196
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(fontSize)
        
        label.frame = CGRect(x: 20, y: 72, width: deviceWidth-40, height: 500)

        label.text = "    " + textJokeS[indexPath.section].text!
        
        label.sizeToFit()

        return label.frame.height + 108
            
            
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
 
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("textJokeCell") as! TextCell
        
        cell.showDetails(textJokeS[indexPath.section])
        cell.delegate = self
        if textJokeS.count - 1 == indexPath.section {
            self.flag = 0
        }
        
        return cell
        
    }

  
}

extension TextViewController : UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return  UIBarPosition.TopAttached
    }
}
