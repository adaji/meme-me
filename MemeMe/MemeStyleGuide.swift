//
//  MemeStyleGuide.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

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
        return UIColor.clearColor()
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
        return "clear"
    }
}

