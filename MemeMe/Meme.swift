//
//  Meme.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Meme: NSObject

class Meme: NSManagedObject {
    
    // MARK: Keys
    
    struct Keys {
        static let SentDate = "sentDate"
        static let TextAttributesDictionary = "textAttributesDictionary"
        static let FontNameIndex = "fontNameIndex"
        static let TextColorIndex = "textColorIndex"
        static let StrokeColorIndex = "strokeColorIndex"
        static let TopText = "topText"
        static let BottomText = "bottomText"
        static let OriginalImageName = "originalImageName"
        static let MemedImageName = "memedImageName"
    }
    
    // MARK: Properties
    
    @NSManaged var sentDate: NSDate
    @NSManaged var fontNameIndex: NSNumber
    @NSManaged var textColorIndex: NSNumber
    @NSManaged var strokeColorIndex: NSNumber
    @NSManaged var topText: String
    @NSManaged var bottomText: String
    @NSManaged var originalImageName: String
    @NSManaged var memedImageName: String
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Meme", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        sentDate = dictionary[Keys.SentDate] as! NSDate
        let textAttributesDictionary = dictionary[Keys.TextAttributesDictionary] as! [String: AnyObject]
        fontNameIndex = textAttributesDictionary[Keys.FontNameIndex] as! NSNumber
        textColorIndex = textAttributesDictionary[Keys.TextColorIndex] as! NSNumber
        strokeColorIndex = textAttributesDictionary[Keys.StrokeColorIndex] as! NSNumber
        topText = dictionary[Keys.TopText] as! String
        bottomText = dictionary[Keys.BottomText] as! String
        originalImageName = dictionary[Keys.OriginalImageName] as! String
        memedImageName = dictionary[Keys.MemedImageName] as! String
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
                    Keys.FontNameIndex : 1,
                    Keys.TextColorIndex : 1,
                    Keys.StrokeColorIndex : 0,
                ],
                Keys.OriginalImageName: Meme.saveImageWithName("funnyGuy") ?? "",
                Keys.MemedImageName: Meme.saveImageWithName("funnyGuy_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-5),
                Keys.TopText: "Don't you think that if I were wrong,",
                Keys.BottomText: "I'd know it?",
                Keys.TextAttributesDictionary: [
                    Keys.FontNameIndex : 0,
                    Keys.TextColorIndex : 0,
                    Keys.StrokeColorIndex : 0,
                ],
                Keys.OriginalImageName: Meme.saveImageWithName("sheldon") ?? "",
                Keys.MemedImageName: Meme.saveImageWithName("sheldon_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-2),
                Keys.TopText: "Day 37:",
                Keys.BottomText: "They still do not suspect I am a mere cat.",
                Keys.TextAttributesDictionary: [
                    Keys.FontNameIndex : 1,
                    Keys.TextColorIndex : 3,
                    Keys.StrokeColorIndex : 1,
                ],
                Keys.OriginalImageName: Meme.saveImageWithName("cat") ?? "",
                Keys.MemedImageName: Meme.saveImageWithName("cat_memed") ?? ""],
            [Keys.SentDate: Meme.dateByAddingDays(-1),
                Keys.TopText: "Homework due at midnight...",
                Keys.BottomText: "Got everything turned in at 11:59 pm",
                Keys.TextAttributesDictionary: [
                    Keys.FontNameIndex : 0,
                    Keys.TextColorIndex : 2,
                    Keys.StrokeColorIndex : 1,
                ],
                Keys.OriginalImageName: Meme.saveImageWithName("successKid") ?? "",
                Keys.MemedImageName: Meme.saveImageWithName("successKid_memed") ?? ""]
        ]
        var memes = [Meme]()
        
        var i: Int = 0
        for memeDic: [String: AnyObject] in memeDictionaries {
            let meme = Meme(dictionary: memeDic, context: CoreDataStackManager.sharedInstance().managedObjectContext)
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











