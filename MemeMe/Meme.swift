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
