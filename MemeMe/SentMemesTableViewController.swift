//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController, MemeEditorViewControllerDelegate {
    
    var memes: [Meme]!
    var hasNewMemeToDisplay: Bool!
    
    func didSendMeme(meme: Meme) {
        memes.append(meme)
        hasNewMemeToDisplay = true
    }
    
    @IBAction func createMeme(sender: UIBarButtonItem) {
        let memeEditorVC = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        memeEditorVC.delegate = self
        
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        hasNewMemeToDisplay = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // For better performance, insert new meme at the end
        if hasNewMemeToDisplay! {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: tableView.numberOfRowsInSection(0), inSection: 0)], withRowAnimation: .Automatic)
            hasNewMemeToDisplay = false
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateGroups.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateGroups[section]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? memes.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")! as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        cell.setMeme(meme.originalImage, topText: meme.topText, bottomText: meme.bottomText, textAttributes: meme.textAttributes, sentDate: stringFromDate(meme.sentDate))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = memes[indexPath.row]
        
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
}

















