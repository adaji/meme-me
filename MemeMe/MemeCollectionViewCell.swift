//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    func setMeme(image: UIImage, top: String, bottom: String, attributes: [String: AnyObject]) {
        memeImageView.image = image

        let textAttributes = textAttributesWithFontSize(attributes, size: 14)
        topLabel.attributedText = NSAttributedString(string: top, attributes: textAttributes)
        bottomLabel.attributedText = NSAttributedString(string: bottom, attributes: textAttributes)
    }
    
}
