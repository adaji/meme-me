//
//  Meme.swift
//  MemeMe
//
//  Created by Ada Ji on 10/19/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import Foundation
import UIKit

class Meme: NSObject {
    var originalImage: UIImage!
    var topText: NSString!
    var bottomText: NSString!
    var memedImage: UIImage!

    init(originalImage: UIImage!, topText: NSString!, bottomText: NSString!, memedImage: UIImage!) {
        self.originalImage = originalImage
        self.topText = topText
        self.bottomText = bottomText
        self.memedImage = memedImage
    }
}

