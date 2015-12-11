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
    
    // If a cell is selected, gray out its image
    // Otherwise, display its original image
    func update(selected: Bool) {
        for view in subviews {
            view.alpha = selected ? 0.5 : 1.0
        }
    }

}
