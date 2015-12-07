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
    
    enum FontName: Int {
        case FontName0
        case FontName1
        case FontName2
        case FontName3
        case FontName4
        case FontName5
    }
    
    enum TextColor: Int {
        case White
        case Red
        case Blue
        case Black
    }
    
    enum StrokeColor: Int {
        case Black
        case White
        case Red
        case Blue
    }
    
    struct TextAttributes {
        static let FontNames = ["Impact", "IMPACTED", "Impacted 2.0", "New", "Thanatos", "Danger Diabolik"]
        static let TextColorStrings = ["white", "red", "blue", "black"]
        static let StrokeColorStrings = ["black", "white", "red", "blue"]
    }
    
    struct FontSizes {
        static let Full: CGFloat = 40.0
        static let Preview: CGFloat = 14.0
    }
    
    class func fontNameWithIndex(index: Int) -> String {
        switch index {
        case FontName.FontName0.rawValue:
            return "Impact"
        case FontName.FontName1.rawValue:
            return "IMPACTED"
        case FontName.FontName2.rawValue:
            return "Impacted 2.0"
        case FontName.FontName3.rawValue:
            return "New"
        case FontName.FontName4.rawValue:
            return "Thanatos"
        case FontName.FontName5.rawValue:
            return "Danger Diabolik"
        default:
            assert(false, "Unexpected font name")
        }
    }
    
    class func indexForFontName(fontName: String) -> Int {
        switch fontName {
            case "Impact":
            return FontName.FontName0.rawValue
            case "IMPACTED":
            return FontName.FontName1.rawValue
            case "Impacted 2.0":
            return FontName.FontName2.rawValue
            case "New":
            return FontName.FontName3.rawValue
            case "Thanatos":
            return FontName.FontName4.rawValue
            case "Danger Diabolik":
            return FontName.FontName5.rawValue
        default:
            assert(false, "Unexpected font name")
        }
    }
    
    class func textColorWithIndex(index: Int) -> UIColor {
        switch index {
        case TextColor.White.rawValue:
            return UIColor.whiteColor()
        case TextColor.Black.rawValue:
            return UIColor.blackColor()
        case TextColor.Red.rawValue:
            return UIColor.redColor()
        case TextColor.Blue.rawValue:
            return UIColor.blueColor()
        default:
            assert(false, "Unexpected text color")
        }
    }
    
    class func indexForTextColor(textColor: UIColor) -> Int {
        switch textColor {
        case UIColor.whiteColor():
            return TextColor.White.rawValue
        case UIColor.blackColor():
            return TextColor.Black.rawValue
        case UIColor.redColor():
            return TextColor.Red.rawValue
        case UIColor.blueColor():
            return TextColor.Blue.rawValue
        default:
            assert(false, "Unexpected text color")
        }
    }
    
    class func strokeColorWithIndex(index: Int) -> UIColor {
        switch index {
        case StrokeColor.White.rawValue:
            return UIColor.whiteColor()
        case StrokeColor.Black.rawValue:
            return UIColor.blackColor()
        case StrokeColor.Red.rawValue:
            return UIColor.redColor()
        case StrokeColor.Blue.rawValue:
            return UIColor.blueColor()
        default:
            assert(false, "Unexpected stroke color")
        }
    }
    
    class func indexForStrokeColor(strokeColor: UIColor) -> Int {
        switch strokeColor {
        case UIColor.whiteColor():
            return StrokeColor.White.rawValue
        case UIColor.blackColor():
            return StrokeColor.Black.rawValue
        case UIColor.redColor():
            return StrokeColor.Red.rawValue
        case UIColor.blueColor():
            return StrokeColor.Blue.rawValue
        default:
            assert(false, "Unexpected stroke color")
        }
    }
    
    // Convert UITextField's textAttributes to Meme's textAttributes dictionary
    class func textAttributesDictionary(textAttributes: [String: AnyObject]) -> [String: AnyObject] {
        return [
            Keys.FontNameIndex: Meme.indexForFontName(textAttributes[NSFontAttributeName]!.fontName),
            Keys.TextColorIndex: Meme.indexForTextColor(textAttributes[NSForegroundColorAttributeName] as! UIColor),
            Keys.StrokeColorIndex: Meme.indexForStrokeColor(textAttributes[NSStrokeColorAttributeName] as! UIColor)
        ]
    }
    
    // Convert Meme's textAttributes dictionary to UITextField's textAttributes
    class func textAttributesForMeme(meme: Meme) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: Meme.fontNameWithIndex(meme.fontNameIndex.integerValue), size: FontSizes.Full)!,
            NSForegroundColorAttributeName : Meme.textColorWithIndex(meme.textColorIndex.integerValue),
            NSStrokeColorAttributeName : Meme.strokeColorWithIndex(meme.strokeColorIndex.integerValue),
            NSStrokeWidthAttributeName : -4
        ]
    }
    
    class func previewTextAttributesForMeme(meme: Meme) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: Meme.fontNameWithIndex(meme.fontNameIndex.integerValue), size: FontSizes.Preview)!,
            NSForegroundColorAttributeName : Meme.textColorWithIndex(meme.textColorIndex.integerValue),
            NSStrokeColorAttributeName : Meme.strokeColorWithIndex(meme.strokeColorIndex.integerValue),
            NSStrokeWidthAttributeName : -4
        ]
    }
    
    class func textAttributes(fontNameIndex: Int, textColorIndex: Int, strokeColorIndex: Int) -> [String: AnyObject] {
        return [
            NSFontAttributeName : UIFont(name: Meme.fontNameWithIndex(fontNameIndex), size: FontSizes.Full)!,
            NSForegroundColorAttributeName : Meme.textColorWithIndex(textColorIndex),
            NSStrokeColorAttributeName : Meme.strokeColorWithIndex(strokeColorIndex),
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
    
    // MARK: Image
    
    class func imageNameFromDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.stringFromDate(date)
    }
    
    class func imagePathWithName(name: String) -> String {
        let dirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        return dirURL.URLByAppendingPathComponent(name).path!
    }
    
    class func imageWithName(name: String) -> UIImage? {
        let dirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let path = dirURL.URLByAppendingPathComponent(name).path!
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }

}

















