//
//  WebDetailViewController.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/10/4.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit

class WebDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var pictureJoke: GeneralJoke!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRecognizer.delegate = self
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        
        webView.addGestureRecognizer(swipeRecognizer)
        
        
        let gifPath = paths[0]+"/alljokes/"+pictureJoke.gifid!+".gif"
        if NSFileManager.defaultManager().fileExistsAtPath(gifPath) {
            
            let data = NSData(contentsOfFile: gifPath)
            
            webView.opaque = false
            webView.backgroundColor = UIColor.whiteColor()
            webView.contentMode = UIViewContentMode.Center
            webView.scalesPageToFit = true
            webView.userInteractionEnabled = true
            
            webView.loadData(data!, MIMEType: "image/gif", textEncodingName: "\(pictureJoke.id!)", baseURL: NSURL(string: "\(pictureJoke.jokeImage!)")!)
            
            
//            let tapRecognizer = UITapGestureRecognizer(target: self, action: "tap")
//            tapRecognizer.delegate = self
//            webView.addGestureRecognizer(tapRecognizer)
            
        }
        
        

    }

    @IBAction func close(sender: UIButton) {
        swipeRight()
    }
    
    func swipeRight() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
