//
//  PictureTableViewController.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit
import CoreData



var deviceWidth: CGFloat!

class PictureViewController: UIViewController , MoreTableViewControllerDelegate, UIGestureRecognizerDelegate, PictureCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var pictureJokeS = [GeneralJoke]()
    var tempJokeS = [GeneralJoke]()
    var hassearched = false
    var hasResults = false
    var flag = 0
    var currentPage = 1
    var timer: NSTimer?
    var generalJokeS = [GeneralJoke]()
    var managedObjectContext: NSManagedObjectContext!
    var jokeWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceWidth = self.view.bounds.width

        let fetch = NSFetchRequest(entityName: "GeneralJoke")
        fetch.predicate = NSPredicate(format: "jokeType = %@", "Picture")
        
        do {
            generalJokeS = [GeneralJoke]()
            generalJokeS = try managedObjectContext.executeFetchRequest(fetch) as! [GeneralJoke]
            
        } catch {
            fatalError()
        }
        
        for generalJoke in generalJokeS {
            pictureJokeS.append(generalJoke)
        }

        self.pictureJokeS.sortInPlace({ (r1, r2) -> Bool in
            return r1.create_time!.localizedStandardCompare(r2.create_time!) == NSComparisonResult.OrderedDescending
        })
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeftRecognizer.delegate = self
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        swipeRightRecognizer.delegate = self
        
        tableView.addGestureRecognizer(swipeLeftRecognizer)
        tableView.addGestureRecognizer(swipeRightRecognizer)

        let nibtextJokeCell = UINib(nibName: "PictureCell", bundle: nil)
        tableView.registerNib(nibtextJokeCell, forCellReuseIdentifier: "pictureJokecell")
        tableView.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "reFresh")
        tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "footReFresh")
        getDataFromInternet(10, page: 1)

       
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if pictureJokeS.count == 0 {
            tableView.header.beginRefreshing()
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let statusType = IJReachability.isConnectedToNetworkOfType()
        switch statusType {
        case .WWAN:
            print("Connection Type: Mobile")
            let alert = UIAlertController(title: "您正在使用流量上网", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let Action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(Action)
            
            presentViewController(alert, animated: true, completion: nil)
        case .WiFi:
            print("Connection Type: WiFi")
            if pictureJokeS.count == 0 {
                getDataFromInternet(10, page: 1)
            }
        case .NotConnected:
            let alert = UIAlertController(title: "无法连接到网络，请检查您的网络", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
            
            
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

    func swipeLeft() {
        let vcs = tabBarController?.viewControllers
        let videoVC = vcs![2]
        tabBarController?.selectedViewController = videoVC
    }
    
    func swipeRight() {
        let vcs = tabBarController?.viewControllers
        let textVC = vcs![0]
        tabBarController?.selectedViewController = textVC
    }
    
    func removeAllAndReLoadData(controller: MoreTableViewController) {
        generalJokeS.removeAll()
        pictureJokeS.removeAll()
        if tableView != nil {
            tableView.reloadData()
        }
        
    }
    
    func justReloadData(controller: MoreTableViewController) {
        if tableView != nil {
            tableView.reloadData()
        }
    }
    
    func showAlert(pictureJokecopy: GeneralJoke, text: String, pictureURL: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let sendToFriendAction = UIAlertAction(title: "分享到朋友圈", style: UIAlertActionStyle.Default) { (_) -> Void in
            //分享朋友圈
            let message:WXMediaMessage = WXMediaMessage()
            message.mediaTagName = "Funnyjokes"
            let ext:WXImageObject = WXImageObject()
            ext.imageData = NSData(contentsOfFile: paths[0]+"/alljokes/"+pictureJokecopy.gifid!+".gif")
            
            message.mediaObject = ext
            let req = SendMessageToWXReq()
            req.scene = 1
            req.text = text
            req.bText = false
            req.message = message
            WXApi.sendReq(req)
            
        }
        
        let sendToFriendSAction = UIAlertAction(title: "分享给好友", style: UIAlertActionStyle.Default) { (_) -> Void in
            //分享给好友
            let message:WXMediaMessage = WXMediaMessage()
            message.mediaTagName = "Funnyjokes"
            let ext:WXImageObject = WXImageObject()
            ext.imageData = NSData(contentsOfFile: paths[0]+"/alljokes/"+pictureJokecopy.gifid!+".gif")
            
            message.mediaObject = ext
            let req = SendMessageToWXReq()
            req.scene = Int32(WXSceneSession.rawValue)
            req.text = text
            req.bText = false
            req.message = message
            WXApi.sendReq(req)
            
            
        }
        
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(sendToFriendAction)
        alert.addAction(sendToFriendSAction)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func reFresh() {
        getDataFromInternet(10, page: 1)
    }
    
    func footReFresh() {
        getDataFromInternet(10, page: ++currentPage)
    }
    
    @IBAction func reFreshBTnChecked(sender: UIBarButtonItem) {
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
                            
                            self.pictureJokeS.appendContentsOf(self.tempJokeS)
                            
                            self.pictureJokeS.sortInPlace({ (r1, r2) -> Bool in
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
    
    
    func parerJSON(jsondata: NSData) -> [String: AnyObject]? {
        
        // NSdata类型变为 字典
        
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsondata, options: NSJSONReadingOptions(rawValue: 0))
            
            let resultDictionary = jsonResult as! [String: AnyObject]
            
            print("json dic: \(resultDictionary)")
            
            return resultDictionary
        }
        catch {
            
            getDataFromInternet(10, page: ++currentPage)
            
        }
        
        return nil
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
        fetch.predicate = NSPredicate(format: "jokeType = %@", "Picture")
        do {
            jokesHadSave = try managedObjectContext.executeFetchRequest(fetch) as! [GeneralJoke]
        } catch {
            fatalError()
        }
        
        tempJokeS.removeAll()
        
        for result in contentlist {

            var a = 0
            let id = result["id"] as? String
            let jokeImage = result["image3"] as? String
            let originStr = result["text"] as? NSString
            
            let rightText = originStr?.stringByReplacingOccurrencesOfString("\n", withString: "")
            
            for one in tempJokeS {
                if one.id == id || one.jokeImage == jokeImage {
                    a = 1
                    break
                }
            }
            
            for one in jokesHadSave {
                if one.id == id || one.jokeImage == jokeImage {
                    a = 1
                    break
                }
            }
            
            if a == 1 {
                a = 0
                continue
            }
            
            let onejoke = NSEntityDescription.insertNewObjectForEntityForName("GeneralJoke", inManagedObjectContext: managedObjectContext) as! GeneralJoke
            
            onejoke.jokeType = "Picture"
            
//            onejoke.text = result["text"] as? String
            onejoke.text = rightText
            
            onejoke.create_time = result["create_time"] as? String
            onejoke.hate = result["hate"] as? String
            onejoke.love = result["love"] as? String
            onejoke.name = result["name"] as? String
            onejoke.profile_image = result["profile_image"] as? String
            onejoke.weixin_url = result["weixin_url"] as? String
            onejoke.jokeImage = result["image3"] as? String
            onejoke.id = result["id"] as? String
            onejoke.gifid = onejoke.id! + "01"

            
            if let profile_image = onejoke.profile_image {
                downloadPicture(profile_image, pictureID: onejoke.id!,flag: true)
            }
            if let jokeImage = onejoke.jokeImage {
                downloadPicture(jokeImage, pictureID: onejoke.gifid!,flag: false)
            }
            
            tempJokeS.append(onejoke)
            
        }
        
    }
    
    
    
    func downloadPicture(profile_image: String,pictureID: String, flag: Bool) {
        
        let profileURL = NSURL(string: profile_image)
        let session = NSURLSession.sharedSession()

        
//        let request = NSMutableURLRequest(URL: profileURL! , cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
//        request.HTTPMethod = "GET"
//        jokeWebView.loadRequest(request)
        
        
        
        let dataTask = session.dataTaskWithURL(profileURL!, completionHandler: { (data, responder, error) -> Void in
            if let error = error {
                print("error: \(error)")
            } else {
                if let httpHeader = responder as? NSHTTPURLResponse {
                    
                    if httpHeader.statusCode == 200 {
                        
                        
                        self.savePicture(data!, pictureID: pictureID,flag: flag)
                        
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

    func savejokesToCoreData() {
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError()
        }
            

    }
    
    func savePicture(data: NSData, pictureID: String, flag: Bool) {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        var path = paths[0]+"/alljokes/"+pictureID+".png"
        
        if flag {
            
            path = paths[0]+"/alljokes/"+pictureID+".png"
            
            
        } else {
            path = paths[0]+"/alljokes/"+pictureID+".gif"
            
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return
        }
        
        do {
            try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
        } catch {
            print("写入失败")
            
        }
        
        
        
    }
    
}

extension PictureViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return pictureJokeS.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 196
        
        
    }
//
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("pictureJokecell") as! PictureCell
        
        cell.textJokelabel.font = UIFont.systemFontOfSize(fontSize)
        cell.textJokelabel.text = pictureJokeS[indexPath.section].text!
        
        cell.textJokelabel.sizeToFit()
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        
        let gifPath = paths[0]+"/alljokes/"+pictureJokeS[indexPath.section].gifid!+".gif"
        
        if NSFileManager.defaultManager().fileExistsAtPath(gifPath) {
            
            let data = NSData(contentsOfFile: gifPath)
            let image = UIImage(data: data!)
            
            let height = image!.size.height
            let width = image!.size.width
            let scare = height/width

            var trueWidth = width
            
            if width > view.bounds.width-80 {
                pictureJokeS[indexPath.section].width = view.bounds.width-80
                trueWidth = view.bounds.width-80
                
            } else {
                pictureJokeS[indexPath.section].width = width
            }
            
            if scare * trueWidth > view.bounds.height-174 {
                
                pictureJokeS[indexPath.section].height = view.bounds.height-174
            } else {
                
                pictureJokeS[indexPath.section].height = scare * trueWidth
            }
            
            if (width > view.bounds.width-80) || (height > view.bounds.height-174) {
                pictureJokeS[indexPath.section].webUIEnable = true
            } else {
                pictureJokeS[indexPath.section].webUIEnable = false
            }
            
            
            return CGFloat(pictureJokeS[indexPath.section].height!)+174+cell.textJokelabel.frame.size.height
            
        } else {
            return 174+cell.textJokelabel.frame.size.height + 200
        }
            
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("pictureVCgotoWebVC", sender: indexPath.section)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("pictureJokecell") as! PictureCell
        
        cell.showDetails(pictureJokeS[indexPath.section])
        cell.delegate = self
        if pictureJokeS.count - 1 == indexPath.section {
            self.flag = 0
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pictureVCgotoWebVC" {
            let webVC = segue.destinationViewController as! WebDetailViewController
            let num = sender as! Int
            webVC.pictureJoke = pictureJokeS[num]
        }
    }

    
    
}


extension PictureViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return  UIBarPosition.TopAttached
    }
}