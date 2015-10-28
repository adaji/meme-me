//
//  MemeStyleGuide.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

let dateGroups = ["Latest", "Older"]

// Date format
// Today: time only, e.g. "10:30"
// Yesterday: "Yesterday"
// This week: weekday only, e.g. "Monday"
// Before this week: date only, e.g. "09/28/15"
func stringFromDate(date: NSDate) -> String {
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

func textAttributesWithFontSize(attributes: [String: AnyObject], size: CGFloat) -> [String: AnyObject] {
    var textAttributes = attributes
    textAttributes[NSFontAttributeName] = UIFont(name: (attributes[NSFontAttributeName]?.fontName)!, size: size)
    
    return textAttributes
}

func stringToColor(colorName: String) -> UIColor {
    switch colorName {
    case "white":
        return UIColor.whiteColor()
    case "black":
        return UIColor.blackColor()
    case "red":
        return UIColor.redColor()
    case "blue":
        return UIColor.blueColor()
    default:
        assert(false, "Unknown color")
    }
}

func colorToString(color: UIColor) -> String {
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
        assert(false, "Unknown color")
    }
}













