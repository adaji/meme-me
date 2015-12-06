//
//  MemeStyleGuide.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Meme (Style Guide)

extension Meme {
    
    // MARK: Text Attributes
    
    struct TextAttributes {
        static let FontNames = ["Impact", "IMPACTED", "Impacted 2.0", "New", "Thanatos", "Danger Diabolik"]
        static let TextColorStrings = ["white", "red", "blue", "black"]
        static let StrokeColorStrings = ["black", "white", "red", "blue"]
    }
    
    struct FontSizes {
        static let Full: CGFloat = 40.0
        static let Preview: CGFloat = 14.0
    }
    
    class func colorFromString(colorString: String) -> UIColor {
        switch colorString {
        case "white":
            return UIColor.whiteColor()
        case "black":
            return UIColor.blackColor()
        case "red":
            return UIColor.redColor()
        case "blue":
            return UIColor.blueColor()
        default:
            assert(false, "Unexpected color")
        }
    }
    
    class func stringFromColor(color: UIColor) -> String {
        switch color {
        case UIColor.whiteColor():
            return "white"
        case UIColor.blackColor():
            return "black"
        case UIColor.redColor():
            return "red"
        case UIColor.blueColor():
            return "blue"
        default:
            assert(false, "Unexpected color")
        }
    }
    
    // Convert UITextField's textAttributes to Meme's textAttributes dictionary
    class func textAttributesDictionary(textAttributes: [String: AnyObject]) -> [String: AnyObject] {
        return [
            Keys.FontName: textAttributes[NSFontAttributeName]!.fontName,
            Keys.TextColorString: Meme.stringFromColor(textAttributes[NSForegroundColorAttributeName] as! UIColor),
            Keys.StrokeColorString: Meme.stringFromColor(textAttributes[NSStrokeColorAttributeName] as! UIColor)
        ]
    }
    
    // Convert Meme's textAttributes dictionary to UITextField's textAttributes
    class func textAttributesForMeme(meme: Meme) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: meme.fontName, size: FontSizes.Full)!,
            NSForegroundColorAttributeName : Meme.colorFromString(meme.textColorString),
            NSStrokeColorAttributeName : Meme.colorFromString(meme.strokeColorString),
            NSStrokeWidthAttributeName : -4
        ]
    }
    
    class func textAttributes(fontName: String, textColorString: String, strokeColorString: String) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: fontName, size: FontSizes.Full)!,
            NSForegroundColorAttributeName : Meme.colorFromString(textColorString),
            NSStrokeColorAttributeName : Meme.colorFromString(strokeColorString),
            NSStrokeWidthAttributeName : -4
        ]
    }
    
    class func previewTextAttributesForMeme(meme: Meme) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: meme.fontName, size: FontSizes.Preview)!,
            NSForegroundColorAttributeName : Meme.colorFromString(meme.textColorString),
            NSStrokeColorAttributeName : Meme.colorFromString(meme.strokeColorString),
            NSStrokeWidthAttributeName : -4
        ]
    }
    
    // MARK: Date Formats
    
    // Date format
    // Today: time only, e.g. "10:30"
    // Yesterday: "Yesterday"
    // This week: weekday only, e.g. "Monday"
    // Before this week: date only, e.g. "09/28/15"
    class func stringFromDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        if calendar.compareDate(date, toDate: today, toUnitGranularity: .Day) == .OrderedSame {
            formatter.dateFormat = "HH:mm"
        }
        else {
            let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: today, options: NSCalendarOptions(rawValue: 0))!
            if calendar.compareDate(date, toDate: yesterday, toUnitGranularity: .Day) == .OrderedSame {
                return "Yesterday"
            }
            else if calendar.compareDate(date, toDate: today, toUnitGranularity: .WeekOfYear) == .OrderedSame {
                formatter.dateFormat = "EEEE"
            }
            else {
                formatter.dateFormat = "MM/dd/yy"
            }
        }
        
        return formatter.stringFromDate(date)
    }
    
    // MARK: Image Name
    
    class func imageNameFromDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.stringFromDate(date)
    }
    
}

// Meme Group

enum MemeGroup: Int {
    case Web = 0
    case Mine
}

enum ReversedMemeGroup: Int {
    case Mine = 0
    case Web
}

let MemeGroups = ["Funny Memes From Web", "My Memes"]
let ReversedMemeGroups = ["My Memes", "Funny Memes From Web"]














