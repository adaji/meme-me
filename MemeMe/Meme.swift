//
//  Meme.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Meme: NSObject

class Meme: NSObject {
    
    // MARK: Keys
    
    struct Keys {
        static let SentDate = "sentDate"
        static let TextAttributesDictionary = "textAttributesDictionary"
        static let FontName = "fontName"
        static let TextColorString = "textColorString"
        static let StrokeColorString = "strokeColorString"
        static let TopText = "topText"
        static let BottomText = "bottomText"
        static let OriginalImagePath = "originalImagePath"
        static let MemedImagePath = "memedImagePath"
    }
    
    // MARK: Properties
    
    var sentDate = NSDate()
    var fontName = ""
    var textColorString = ""
    var strokeColorString = ""
    var topText = ""
    var bottomText = ""
    var originalImagePath = ""
    var memedImagePath = ""
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        sentDate = dictionary[Keys.SentDate] as! NSDate
        let textAttributesDictionary = dictionary[Keys.TextAttributesDictionary] as! [String: AnyObject]
        fontName = textAttributesDictionary[Keys.FontName] as! String
        textColorString = textAttributesDictionary[Keys.TextColorString] as! String
        strokeColorString = textAttributesDictionary[Keys.StrokeColorString] as! String
        topText = dictionary[Keys.TopText] as! String
        bottomText = dictionary[Keys.BottomText] as! String
        originalImagePath = dictionary[Keys.OriginalImagePath] as! String
        memedImagePath = dictionary[Keys.MemedImagePath] as! String
    }
    
}

// MARK: - Meme (Local Memes)

extension Meme {
    
    // Generate an array of local memes
    static var localMemes: [Meme] {

        let memeDictionaries: [[String: AnyObject]] = [
            [Keys.SentDate: Meme.dateByAddingDays(-10),
                Keys.TopText: "I changed all my passwords to \"incorrect\"",
                Keys.BottomText: "So whenever I forget, it will tell me \"Your password is incorrect\"",
                Keys.TextAttributesDictionary: [
                    Keys.FontName : "IMPACTED",
                    Keys.TextColorString : "red",
                    Keys.StrokeColorString : "black",
                ],
                Keys.OriginalImagePath: Meme.saveImageWithName("funnyGuy") ?? "",
                Keys.MemedImagePath: Meme.saveImageWithName("funnyGuy_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-5),
                Keys.TopText: "Don't you think that if I were wrong,",
                Keys.BottomText: "I'd know it?",
                Keys.TextAttributesDictionary: [
                    Keys.FontName : "Impact",
                    Keys.TextColorString : "white",
                    Keys.StrokeColorString : "black",
                ],
                Keys.OriginalImagePath: Meme.saveImageWithName("sheldon") ?? "",
                Keys.MemedImagePath: Meme.saveImageWithName("sheldon_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-2),
                Keys.TopText: "Day 37:",
                Keys.BottomText: "They still do not suspect I am a mere cat.",
                Keys.TextAttributesDictionary: [
                    Keys.FontName : "IMPACTED",
                    Keys.TextColorString : "black",
                    Keys.StrokeColorString : "white",
                ],
                Keys.OriginalImagePath: Meme.saveImageWithName("cat") ?? "",
                Keys.MemedImagePath: Meme.saveImageWithName("cat_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-1),
                Keys.TopText: "Homework due at midnight...",
                Keys.BottomText: "Got everything turned in at 11:59 pm",
                Keys.TextAttributesDictionary: [
                    Keys.FontName : "Impact",
                    Keys.TextColorString : "blue",
                    Keys.StrokeColorString : "white",
                ],
                Keys.OriginalImagePath: Meme.saveImageWithName("successKid") ?? "",
                Keys.MemedImagePath: Meme.saveImageWithName("successKid_memed") ?? ""]
        ]
        var memes = [Meme]()
        
        var i: Int = 0
        for memeDic: [String: AnyObject] in memeDictionaries {
            let meme = Meme(dictionary: memeDic)
            memes.append(meme)
            
            i++
        }
        
        return memes
    }
    
    // MARK: Helpers
    
    // Save image to Document Directory, and return the file path
    class func saveImageWithName(name: String) -> String? {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imagePath = NSURL.fileURLWithPathComponents([dirPath, name + ".jpg"])!.path!

        if !NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
            if UIImageJPEGRepresentation(UIImage(named: name)!, 1.0)!.writeToFile(imagePath, atomically: false) {
                print("Original image saved")
                return imagePath
            } else {
                print("Unable to save original image")
                return nil
            }
        } else {
            return imagePath
        }
    }
    
    // Return the date of n days later
    class func dateByAddingDays(nDays: Double) -> NSDate {
        return NSDate().dateByAddingTimeInterval(nDays*24*60*60)
    }
    
}











