//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController, MemeEditorViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editMeme")
        
        imageView.image = Meme.imageWithName(meme.memedImageName)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
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
    
    func memeEditor(memeEditor: MemeEditorViewController, didSentMeme meme: Meme?) {
        if let meme = meme {
            self.meme = meme
        }
    }

}















