//
//  TextCell.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit

protocol TextCellDelegate: class {
    func showAlert(textCell: TextCell, text: String)
}

class TextCell: UITableViewCell {

    @IBOutlet weak var profile_imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var create_timeLabel: UILabel!
    
//    @IBOutlet weak var textJokelabel: UILabel!

    @IBOutlet weak var hateLabel: UILabel!
    
    @IBOutlet weak var loveLabel: UILabel!
//    let manger = WXApi()
    
    var delegate: TextCellDelegate?
    var textJokelabel = UILabel()
    
    
    
    @IBAction func shareBTnChecked(sender: UIButton) {
        delegate?.showAlert(self, text: self.textJokelabel.text!)
    }

    func showDetails(textJoke: GeneralJoke) {
        
        textJokelabel.font = UIFont.systemFontOfSize(fontSize)
        
        nameLabel.text = textJoke.name
        create_timeLabel.text = textJoke.create_time
        
        
//        
//            print("******self.frame.width - pictureJoke.width!:\(deviceWidth - pictureJoke.width!)")
//            print("self.frame.width:\(deviceWidth)")
//            print("pictureJoke.width!:\(pictureJoke.width!)")
        
            
        textJokelabel.frame = CGRect(x: 20, y: 72, width: deviceWidth-40, height: 500)
        
        
        textJokelabel.numberOfLines = 0
        
        textJokelabel.textRectForBounds(CGRect(x: 20, y: 72, width: deviceWidth-40, height: 500), limitedToNumberOfLines: 100)
        
        textJokelabel.text = "    " + textJoke.text!
        
        textJokelabel.sizeToFit()
        
        
        self.addSubview(textJokelabel)
        
        
        
        textJokelabel.contentMode = UIViewContentMode.Center
        
        
        

        hateLabel.text = "讨厌：" + textJoke.hate!
        loveLabel.text = "喜欢：" + textJoke.love!
       
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let path = paths[0]+"/alljokes/"+textJoke.id!+".png"
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            profile_imageView.image = UIImage(contentsOfFile: path)
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
