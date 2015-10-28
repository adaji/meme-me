//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController, MemeEditorViewDelegate {
    
    // Display latest items at the top
    private var reversedLatestMemes: [Meme]!
    private let reversedOlderMemes: [Meme] = Meme.olderMemes.reverse()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reversedLatestMemes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes.reverse()

        // For better performance, only update view(s) for new meme(s)
        let section = ReverseDateGroup.Latest.rawValue
        let rowsCount = tableView.numberOfRowsInSection(section)
        if rowsCount < reversedLatestMemes.count {
            var indexPaths = [NSIndexPath]()
            var row = 0
            for _ in rowsCount...(reversedLatestMemes.count - 1) {
                indexPaths.append(NSIndexPath(forRow: row, inSection: section))
                row++
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            tableView.headerViewForSection(section)?.textLabel?.text = ReverseDateGroups[section] + " (" + String(memesForGroup(section).count) + ")"
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
        return ReverseDateGroups.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ReverseDateGroups[section] + " (" + String(memesForGroup(section).count) + ")"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memesForGroup(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")! as! MemeTableViewCell
        let memes = memesForGroup(indexPath.section)
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
        let memes = memesForGroup(indexPath.section)
        detailVC.meme = memes[indexPath.row]
        
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Meme Editor View Delegate
    
    func didSendMeme(meme: Meme) {
    }
    
    // MARK: Helper Methods
    
    func memesForGroup(group: Int) -> [Meme] {
        switch group {
        case ReverseDateGroup.Latest.rawValue:
            return reversedLatestMemes
        case ReverseDateGroup.Older.rawValue:
            return reversedOlderMemes
        default:
            assert(false, "Unknown date group type")
        }
    }
    
}

















