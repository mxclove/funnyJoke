//
//  VideoCell.swift
//  Funny jokes
//
//  Created by Lxrent46 on 15/8/15.
//  Copyright © 2015年 MACHAO. All rights reserved.
//

import UIKit

protocol VideoCellDelegate: class {
    func showAlert(textCell: VideoCell, text: String, videoURL: String)
}

class VideoCell: UITableViewCell {

    @IBOutlet weak var profile_imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var create_timeLabel: UILabel!
    
    @IBOutlet weak var textJokelabel: UILabel!
    
    @IBOutlet weak var hateLabel: UILabel!
    
    @IBOutlet weak var loveLabel: UILabel!
    
    @IBOutlet weak var videoImageView: UIImageView!

    var delegate: VideoCellDelegate?
    var jokeViedo = String()
    @IBAction func shareBTnChecked(sender: UIButton) {
    
        delegate?.showAlert(self, text: self.textJokelabel.text!, videoURL: jokeViedo)
        
    }
    
    func showDetails(videoJoke: GeneralJoke) {
        jokeViedo = videoJoke.jokeViedo!
        textJokelabel.font = UIFont.systemFontOfSize(fontSize)
        if videoJoke.name != nil {
            
            nameLabel.text = videoJoke.name!
            
            if videoJoke.create_time != nil {
                create_timeLabel.text = videoJoke.create_time!
            }
            
            if videoJoke.text != nil {
                textJokelabel.text = videoJoke.text!
            }
            
            if videoJoke.hate != nil {
                hateLabel.text = "讨厌：" + videoJoke.hate!
            }
            if videoJoke.love != nil {
                loveLabel.text = "喜欢：" + videoJoke.love!
            }
            
            
            
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            
            let path = paths[0]+"/alljokes/"+videoJoke.id!+".png"
            let gifPath = paths[0]+"/alljokes/"+videoJoke.gifid!+".png"
            
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                profile_imageView.image = UIImage(contentsOfFile: path)
            }
            
            
            
            if NSFileManager.defaultManager().fileExistsAtPath(gifPath) {
                
                videoImageView.image = UIImage(contentsOfFile: gifPath)

                
            }

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
