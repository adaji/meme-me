//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var memeTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setMeme(image: UIImage, top: String, bottom: String, attributes: [String: AnyObject], time: String) {
        memeImageView.image = image

        let textAttributes = textAttributesWithFontSize(attributes, size: 14)
        topLabel.attributedText = NSAttributedString(string: top, attributes: textAttributes)
        bottomLabel.attributedText = NSAttributedString(string: bottom, attributes: textAttributes)
        memeTextLabel.text = top + "..." + bottom

        timeLabel.text = time
    }
    
}
