//
//  VideoPlayController.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/9/17.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayController: UIViewController ,UIGestureRecognizerDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var videoPlayer = MPMoviePlayerController()
    var urlString = ""
    var titleString = ""
    var timer: NSTimer?
    var videoJokes = [GeneralJoke]()
    var choose = 0
    var pauseImageView = UIImageView()
    
    
    var activitydicator = UIActivityIndicatorView()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPlayer.controlStyle = MPMovieControlStyle.None
        
        activitydicator.frame = CGRect(x: videoPlayer.view.center.x-10, y: videoPlayer.view.center.y-10, width: 20, height: 20)
        
        activitydicator.color = UIColor.whiteColor()
        activitydicator.hidesWhenStopped = true
        
        activitydicator.startAnimating()

        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updataInformantion", userInfo: nil, repeats: true)
        
        navBar.topItem?.title = titleString

        let url = NSURL(string: urlString)
        videoPlayer.contentURL = url

        videoPlayer.view.frame = CGRect(x: self.view.center.x-self.view.bounds.width/2, y: 64, width: self.view.bounds.width, height: self.view.bounds.height-64)

        view.addSubview(videoPlayer.view)
        videoPlayer.view.addSubview(activitydicator)

        let leftSwip = UISwipeGestureRecognizer(target: self, action: "leftSwip:")
        let rightSwip = UISwipeGestureRecognizer(target: self, action: "rightSwip:")
        
        leftSwip.direction = UISwipeGestureRecognizerDirection.Left
        rightSwip.direction = UISwipeGestureRecognizerDirection.Right
        
        leftSwip.delegate = self
        rightSwip.delegate = self
        
        pauseImageView.frame = CGRect(x: videoPlayer.view.center.x-30, y: videoPlayer.view.center.y-94, width: 60, height: 60)
        
        pauseImageView.image = UIImage(named: "hehehe")
        
        videoPlayer.view.addSubview(pauseImageView)
        pauseImageView.hidden = true
        
        videoPlayer.view.addGestureRecognizer(leftSwip)
        videoPlayer.view.addGestureRecognizer(rightSwip)
        
        videoPlayer.play()


    }

    
    @IBAction func sharevideoBTnChecked(sender: UIBarButtonItem) {
        showAlert(videoJokes[choose].text!, videoURL: videoJokes[choose].jokeViedo!)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point = touch?.locationInView(view)

        if CGRectContainsPoint(videoPlayer.view.frame, point!) {
            if videoPlayer.playbackState == MPMoviePlaybackState.Playing {
                videoPlayer.pause()
                pauseImageView.hidden = false
                
            } else if videoPlayer.playbackState == MPMoviePlaybackState.Paused {
                videoPlayer.play()
                pauseImageView.hidden = true
            }
        }
    }

    
    
    func leftSwip(recongnizer: UIPanGestureRecognizer) {

        if recongnizer.state == UIGestureRecognizerState.Ended {
            videoPlayer.view.removeFromSuperview()
            beginSeekingForward()
        }
    }

    func rightSwip(recongnizer: UIPanGestureRecognizer) {
        if recongnizer.state == UIGestureRecognizerState.Ended {
            videoPlayer.view.removeFromSuperview()
            beginSeekingBackward()
        }
    }
    
    func beginSeekingForward() {
        if choose != videoJokes.count - 1 {
            videoPlayer.view.removeFromSuperview()
            let videoJoke = videoJokes[++choose]
            navBar.topItem?.title = videoJoke.text
            videoPlayer.contentURL = NSURL(string: videoJoke.jokeViedo!)
            view.addSubview(videoPlayer.view)
            videoPlayer.play()
            activitydicator.startAnimating()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updataInformantion", userInfo: nil, repeats: true)
            pauseImageView.hidden = true
        }
    }
    
    
    func beginSeekingBackward() {
        
        if choose != 0 {
            
            let videoJoke = videoJokes[--choose]
            navBar.topItem?.title = videoJoke.text
            videoPlayer.contentURL = NSURL(string: videoJoke.jokeViedo!)
            view.addSubview(videoPlayer.view)
            videoPlayer.play()
            activitydicator.startAnimating()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updataInformantion", userInfo: nil, repeats: true)
            pauseImageView.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillLayoutSubviews() {
        
        videoPlayer.view.frame = CGRect(x: self.view.center.x-self.view.bounds.width/2, y: 64, width: self.view.bounds.width, height: self.view.bounds.height-64)
        
        activitydicator.frame = CGRect(x: videoPlayer.view.center.x-10, y: videoPlayer.view.center.y-10, width: 20, height: 20)
        
        pauseImageView.frame = CGRect(x: videoPlayer.view.center.x-30, y: videoPlayer.view.center.y-94, width: 60, height: 60)
        
        view.addSubview(videoPlayer.view)
        view.addSubview(activitydicator)
    }
    
    func updataInformantion() {
        if activitydicator.isAnimating() {
            if videoPlayer.playbackState == MPMoviePlaybackState.Playing {
                activitydicator.stopAnimating()
                timer?.invalidate()
            } 
        }
    }
    
    @IBAction func goBackAction(sender: UIBarButtonItem) {
        videoPlayer.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert(text: String, videoURL: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let sendToFriendAction = UIAlertAction(title: "分享到朋友圈", style: UIAlertActionStyle.Default) { (_) -> Void in
            //分享朋友圈
            let message:WXMediaMessage = WXMediaMessage()
            message.title = text
            message.description = text

            let ext:WXVideoObject = WXVideoObject()
            ext.videoUrl = videoURL
            message.mediaObject = ext
            let req = SendMessageToWXReq()
            req.scene = 1
            req.text = nil
            req.bText = false
            req.message = message
            WXApi.sendReq(req)
        }
        
        let sendToFriendSAction = UIAlertAction(title: "分享给好友", style: UIAlertActionStyle.Default) { (_) -> Void in
            //分享给好友
            let message:WXMediaMessage = WXMediaMessage()
            message.title = text
            message.description = text

            let ext:WXVideoObject = WXVideoObject()
            ext.videoUrl = videoURL
            message.mediaObject = ext
            
            let req = SendMessageToWXReq()
            req.scene = 0
            req.text = nil
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
    
}

extension VideoPlayController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return  UIBarPosition.TopAttached
    }
    
}
