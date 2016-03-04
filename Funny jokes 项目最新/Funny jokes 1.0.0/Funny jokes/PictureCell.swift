
//
//  PictureCell.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit

let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)

protocol PictureCellDelegate: class {
    func showAlert(pictureJokecopy: GeneralJoke, text: String, pictureURL: String)
}

class PictureCell: UITableViewCell ,UIWebViewDelegate {

    @IBOutlet weak var profile_imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var create_timeLabel: UILabel!
    
    @IBOutlet weak var textJokelabel: UILabel!
    
    @IBOutlet weak var hateLabel: UILabel!
    
    @IBOutlet weak var loveLabel: UILabel!
    
    

    @IBOutlet weak var jokeWebView: UIWebView!
    let activitydicator = UIActivityIndicatorView()
    var delegate: PictureCellDelegate?
    var jokeImage = String()
    var pictureJokecopy: GeneralJoke!

    
    @IBAction func shareBTnChecked(sender: UIButton) {
        delegate?.showAlert(pictureJokecopy, text: self.textJokelabel.text!, pictureURL: jokeImage)
    }
    func showDetails(pictureJoke: GeneralJoke) {
        textJokelabel.font = UIFont.systemFontOfSize(fontSize)
        pictureJokecopy = pictureJoke
        if pictureJoke.width != nil && pictureJoke.height != nil {
        
            jokeWebView.frame = CGRect(x: abs(CGFloat(pictureJoke.width!) - deviceWidth) / 2, y: textJokelabel.frame.origin.y + textJokelabel.frame.height + 13, width: CGFloat(pictureJoke.width!), height: CGFloat(pictureJoke.height!))
        
        }
        
        
        jokeImage = pictureJoke.jokeImage!
        nameLabel.text = pictureJoke.name
        create_timeLabel.text = pictureJoke.create_time
        textJokelabel.text = pictureJoke.text
        hateLabel.text = "讨厌：" + pictureJoke.hate!
        loveLabel.text = "喜欢：" + pictureJoke.love!
        
//        jokeWebView.scalesPageToFit = true
//        let urlString = "http://www.baidu.com"
//        
//        let url = NSURL(string: urlString)
//        
//        let request = NSMutableURLRequest(URL: url! , cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
//        request.HTTPMethod = "GET"
//        
//        jokeWebView.loadRequest(request)

    
        let path = paths[0]+"/alljokes/"+pictureJoke.id!+".png"
        
        let gifPath = paths[0]+"/alljokes/"+pictureJoke.gifid!+".gif"
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
           profile_imageView.image = UIImage(contentsOfFile: path)
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(gifPath) {
                
            let data = NSData(contentsOfFile: gifPath)

            jokeWebView.opaque = false
            jokeWebView.backgroundColor = UIColor.whiteColor()
            jokeWebView.contentMode = UIViewContentMode.Center
            jokeWebView.scalesPageToFit = true
            
//            if let webUIEnable = pictureJoke.webUIEnable  {
//                jokeWebView.userInteractionEnabled = Bool(webUIEnable)
//            } else {
//                jokeWebView.userInteractionEnabled = false
//            }
            jokeWebView.userInteractionEnabled = false
            
            jokeWebView.loadData(data!, MIMEType: "image/gif", textEncodingName: "\(pictureJoke.id!)", baseURL: NSURL(string: "\(pictureJoke.jokeImage!)")!)
            
        }
        
    }

    func webViewDidStartLoad(webView: UIWebView) {
        
        activitydicator.frame = CGRect(x: self.frame.width/2-10, y: self.frame.height/2-10, width: 20, height: 20)
        
        self.addSubview(activitydicator)
        activitydicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.reloadInputViews()
        activitydicator.stopAnimating()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        jokeWebView.delegate = self
        self.selectionStyle = UITableViewCellSelectionStyle.None
        activitydicator.hidesWhenStopped = true
        activitydicator.color = UIColor.redColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
