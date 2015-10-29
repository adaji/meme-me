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
    static var localMemes: [Meme] {
        let SentDateKey = "SentDateKey"
        let TopTextKey = "TopTextKey"
        let BottomTextKey = "BottomTextKey"
        let TextAttributesKey = "TextAttributesKey"
        let OriginalImageKey = "OriginalImageKey"
        let MemedImageKey = "MemedImageKey"
        
        let memeDictionaries: [[String: AnyObject]] = [
            [SentDateKey: 5, TopTextKey: "I changed all my passwords to \"incorrect\"", BottomTextKey: "So whenever I forget, it will tell me \"Your password is incorrect\"", TextAttributesKey: [
                NSFontAttributeName : UIFont(name: "IMPACTED", size: 40)!,
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSStrokeColorAttributeName : UIColor.blackColor(),
                NSStrokeWidthAttributeName : -4
                ], OriginalImageKey: "funnyGuy", MemedImageKey: "funnyGuy_memed"],
            [SentDateKey: 2, TopTextKey: "Don't you think that if I were wrong,", BottomTextKey: "I'd know it?", TextAttributesKey: [
                NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSStrokeColorAttributeName : UIColor.blackColor(),
                NSStrokeWidthAttributeName : -4
                ], OriginalImageKey: "sheldon", MemedImageKey: "sheldon_memed"],
            [SentDateKey: 1, TopTextKey: "Day 37:", BottomTextKey: "They still do not suspect I am a mere cat.", TextAttributesKey: [
                NSFontAttributeName : UIFont(name: "IMPACTED", size: 40)!,
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSStrokeColorAttributeName : UIColor.whiteColor(),
                NSStrokeWidthAttributeName : -4
                ], OriginalImageKey: "cat", MemedImageKey: "cat_memed"],
            [SentDateKey: 10, TopTextKey: "Homework due at midnight...", BottomTextKey: "Got everything turned in at 11:59 pm", TextAttributesKey: [
                NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
                NSForegroundColorAttributeName : UIColor.blueColor(),
                NSStrokeColorAttributeName : UIColor.whiteColor(),
                NSStrokeWidthAttributeName : -4
                ], OriginalImageKey: "successKid", MemedImageKey: "successKid_memed"]
        ]
        var memes = [Meme]()
        
        var i: Int = 0
        for memeDic: [String: AnyObject] in memeDictionaries {
            let meme = Meme(sentDate: NSDate(timeInterval: Double(-1 * (memeDic[SentDateKey] as! Int) * 24 * 60 * 60), sinceDate: NSDate()), topText: memeDic[TopTextKey] as! String, bottomText: memeDic[BottomTextKey] as! String, textAttributes: memeDic[TextAttributesKey] as! [String: AnyObject], originalImage: UIImage(named: memeDic[OriginalImageKey] as! String)!, memedImage: UIImage(named: memeDic[MemedImageKey] as! String)!)
            memes.append(meme)
            
            i++
        }
        
        return memes
    }
    
}











