//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController, MemeEditorViewDelegate {
    
    private var memes: [Meme]!
    private let olderMemes: [Meme] = Meme.olderMemes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes

        // For better performance, insert new meme at the end
        let nRows = tableView.numberOfRowsInSection(DateGroup.Latest.rawValue)
        if nRows < memes.count {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: nRows, inSection: DateGroup.Latest.rawValue)], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: Actions
    
    @IBAction func createMeme(sender: UIBarButtonItem) {
        let memeEditorVC = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        memeEditorVC.delegate = self
        
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DateGroups.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateGroups[section]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memesForGroup(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")! as! MemeTableViewCell
        let meme = memesForGroup(indexPath.section)[indexPath.row]
        
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
        detailVC.meme = memesForGroup(indexPath.section)[indexPath.row]
        
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Meme Editor View Delegate
    
    func didSendMeme(meme: Meme) {
    }
    
    // MARK: Helper Methods
    
    func memesForGroup(group: Int) -> [Meme] {
        switch group {
        case DateGroup.Latest.rawValue:
            return memes
        case DateGroup.Older.rawValue:
            return olderMemes
        default:
            assert(false, "Unknown date group type")
        }
    }
    
}

















