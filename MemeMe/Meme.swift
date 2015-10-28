//
//  Meme.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var sentDate: NSDate
    var topText: String
    var bottomText: String
    var textAttributes: [String: AnyObject]
    var originalImage: UIImage
    var memedImage: UIImage
}

extension Meme {
    // Generate an array of local memes
    static var olderMemes: [Meme] {
        let DefaultTextAttributes: [String: AnyObject] = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName : -4 // A negative value means both fill and stroke, 0 means only fill, a positive value means only stroke
        ]
        
        var memes = [Meme]()
        let imageNames = ["1", "2", "3", "4"]
        let nDaysAgoArray: [Int] = [10, 5, 2, 1]
        var i: Int = 0
        for imageName: String in imageNames {
            let meme = Meme(sentDate: NSDate(timeInterval: Double(-1 * nDaysAgoArray[i] * 24 * 60 * 60), sinceDate: NSDate()), topText: "TOP", bottomText: "BOTTOM", textAttributes: DefaultTextAttributes, originalImage: UIImage(named: imageName)!, memedImage: UIImage(named: imageName)!)
            memes.append(meme)
            
            i++
        }
        
        return memes
    }
    
}











