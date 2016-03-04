//
//  MoreTableViewController.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit
import CoreData

var fontSize: CGFloat = 18

protocol MoreTableViewControllerDelegate: class {
    func removeAllAndReLoadData(controller: MoreTableViewController)
    func justReloadData(controller: MoreTableViewController)
}

class MoreTableViewController: UITableViewController, UIGestureRecognizerDelegate, UIPickerViewDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var delegate: MoreTableViewControllerDelegate?
    var delegate1: MoreTableViewControllerDelegate?
    var delegate2: MoreTableViewControllerDelegate?
    var appdelegate = AppDelegate()
    
    
    @IBOutlet weak var fontSizePickerView: UIPickerView!
    
    @IBOutlet weak var sizeOfFile: UILabel!

    @IBOutlet weak var fontSizeLabel: UILabel!
    
    var timer: NSTimer?
    var hudView: HUDView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        swipeRightRecognizer.delegate = self
        tableView.addGestureRecognizer(swipeRightRecognizer)
        fontSizeLabel.text = "\(fontSize)"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        figureOutallFileSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func swipeRight() {
        let vcs = tabBarController?.viewControllers
        let videoVC = vcs![2]
        tabBarController?.selectedViewController = videoVC
    }

    func figureOutallFileSize() {
//        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let path = paths[0]+"/alljokes"
        
        let isExisted = NSFileManager.defaultManager().fileExistsAtPath(path)
        var allFileSize: Float = 0
        if isExisted {
            
            let childFilesEnumerator =  NSFileManager.defaultManager().subpathsAtPath(path)?.enumerate()
            
            if childFilesEnumerator != nil {
                for (n, c) in childFilesEnumerator! {
                   
                    
                    do {
                        
                        let pathss = paths[0]+"/alljokes/"+"\(c)"
                        
                        let bbb = try  NSFileManager.defaultManager().attributesOfItemAtPath(pathss) as NSDictionary
                        
                        let ccc = bbb.fileSize()
                       
                        allFileSize += Float(ccc)
                        
                    } catch {
                        fatalError()
                    }
                }
            }
            
            
        }
        
        if allFileSize < 1024 {
            sizeOfFile.text = "\(allFileSize)B"
        } else if allFileSize/1024 < 1024 {
            sizeOfFile.text = "\(allFileSize/1024)K"
        } else {
            sizeOfFile.text = "\(allFileSize/1024/1024)M"
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 1 {
            showAlert()
        }
        if indexPath.section == 0 && indexPath.row == 0 {
            showFontSizeAlert()
        }
    }

    func showAlert() {
        let alert = UIAlertController(title: "清除缓存", message: "清除缓存有助于节省空间，保留则可以使浏览之前看过的图片速度更快，是否确定清除？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (_) -> Void in
            var all: [GeneralJoke]
            let fetch = NSFetchRequest(entityName: "GeneralJoke")
            do {
                all = try self.managedObjectContext.executeFetchRequest(fetch) as! [GeneralJoke]
            } catch {
                fatalError()
            }
            
            for i in all {
                self.managedObjectContext.deleteObject(i)
            }
            
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError()
            }

            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let gifPath = paths[0]+"/alljokes"
            do {
                try NSFileManager.defaultManager().removeItemAtPath(gifPath)
                
            } catch {
                fatalError()
            }
            
            let path = paths[0]+"/alljokes"
            let isExisted = NSFileManager.defaultManager().fileExistsAtPath(path)
            if !isExisted {
                
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    fatalError()
                }
                
            }
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "dismissDetail", userInfo: nil, repeats: false)
            self.hudView = HUDView.hudViewInView(self.view, animated: true)
            
            self.hudView!.text = "清除成功！"
            
            self.figureOutallFileSize()
            
            
            self.delegate?.removeAllAndReLoadData(self)
            
            self.delegate2?.removeAllAndReLoadData(self)
            
            self.delegate1?.removeAllAndReLoadData(self)
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showFontSizeAlert() {

        let alert = UIAlertController(title: "字体大小", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let size10 = UIAlertAction(title: "10", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 10
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(10, forKey: "FontSize")
        }
        let size12 = UIAlertAction(title: "12", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 12
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(12, forKey: "FontSize")
        }
        
        let size15 = UIAlertAction(title: "15", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 15
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(15, forKey: "FontSize")
        }
        let size18 = UIAlertAction(title: "18", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 18
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(18, forKey: "FontSize")
        }
        let size22 = UIAlertAction(title: "22", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 22
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(22, forKey: "FontSize")
        }
        let size26 = UIAlertAction(title: "26", style: UIAlertActionStyle.Default) { (_) -> Void in
            fontSize = 26
            self.fontSizeLabel.text = "\(fontSize)"
            self.delegate?.justReloadData(self)
            self.delegate1?.justReloadData(self)
            self.delegate2?.justReloadData(self)
            NSUserDefaults.standardUserDefaults().setFloat(26, forKey: "FontSize")
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(size10)
        alert.addAction(size12)
        alert.addAction(size15)
        alert.addAction(size18)
        alert.addAction(size22)
        alert.addAction(size26)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    func dismissDetail() {
        timer?.invalidate()
        hudView!.removeFromSuperview()
    }
   

}
