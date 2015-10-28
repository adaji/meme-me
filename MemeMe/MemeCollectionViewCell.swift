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
    
    func setMeme(image: UIImage, topText: String, bottomText: String, textAttributes: [String: AnyObject]) {
        memeImageView.image = image

        let attributes = textAttributesWithFontSize(textAttributes, size: 14)
        topLabel.attributedText = NSAttributedString(string: topText, attributes: attributes)
        bottomLabel.attributedText = NSAttributedString(string: bottomText, attributes: attributes)
    }
    
}
