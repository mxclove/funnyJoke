//
//  AppDelegate.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        print("\(paths[0])")

        let path = paths[0]+"/alljokes"

        let isExisted = NSFileManager.defaultManager().fileExistsAtPath(path)
        
        if !isExisted {
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建失败")
            }
            
        } else {
            
        }
        
        
        let tabBarController = window?.rootViewController as! UITabBarController
        
        let textVC = tabBarController.viewControllers?[0] as! TextViewController
        let pictureVC = tabBarController.viewControllers?[1] as! PictureViewController
        let videoVC = tabBarController.viewControllers?[2] as! VideoViewController
   
        let naVC = tabBarController.viewControllers?[3] as! UINavigationController
        let moreVC = naVC.topViewController as! MoreTableViewController

        textVC.managedObjectContext = managedObjectContext
        textVC.tableView = UITableView()
        pictureVC.managedObjectContext = managedObjectContext
        pictureVC.tableView = UITableView()
        videoVC.managedObjectContext = managedObjectContext
        videoVC.tableView = UITableView()
        moreVC.managedObjectContext = managedObjectContext

        moreVC.delegate = textVC
        moreVC.delegate1 = pictureVC
        moreVC.delegate2 = videoVC
        
        deviceWidth = window?.bounds.width
        
        WXApi.registerApp("wx61c5763a22503af0")
        

        var font = NSUserDefaults.standardUserDefaults().floatForKey("FontSize")
        if font < 10.0 || font > 28.0 {
            font = 18
        }
        fontSize = CGFloat(font)
        
        customBarConfiger()
        
        return true
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "-.-.Funny_jokes" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Funny_jokes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func customBarConfiger() {
        UINavigationBar.appearance().barTintColor = UIColor(red: 198/255.0, green: 150/255.0, blue: 163/255.0, alpha: 1)
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
//        UITabBar.appearance().barTintColor = UIColor.blackColor()
        
//        let customTintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1)
//        UITabBar.appearance().tintColor = customTintColor
        
    }

}

