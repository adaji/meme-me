//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController, MemeEditorViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editMeme")
        tabBarController?.tabBar.hidden = true
        
        imageView.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.hidden = false
    }
    
    func editMeme() {
        let editorVC = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        editorVC.delegate = self
        editorVC.meme = meme
        presentViewController(editorVC, animated: true, completion: nil)
    }
    
    // MARK: Meme Editor View Delegate
    
    func didSendMeme(meme: Meme) {
        self.meme = meme
    }
    
}















