//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - SentMemesTableViewController: UITableViewController

class SentMemesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    // Display latest items at the top
    private var memes: [Meme]!
    private let localMemes: [Meme] = Meme.localMemes
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes

        // For better performance, only update view(s) for new meme(s)
        let section = ReversedMemeGroup.Mine.rawValue
        let rowsCount = tableView.numberOfRowsInSection(section)
        if rowsCount < memes.count {
            var indexPaths = [NSIndexPath]()
            var row = 0
            for _ in rowsCount...(memes.count - 1) {
                indexPaths.append(NSIndexPath(forRow: row, inSection: section))
                row++
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            tableView.headerViewForSection(section)?.textLabel?.text = ReversedMemeGroups[section] + " (" + String(memesForGroup(section).count) + ")"
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ReversedMemeGroups.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ReversedMemeGroups[section] + " (" + String(memesForGroup(section).count) + ")"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memesForGroup(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")! as! MemeTableViewCell
        let memes = memesForGroup(indexPath.section)
        let meme = memes[memes.count - 1 - indexPath.row]
        
        configureCell(cell, withMeme: meme)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case ReversedMemeGroup.Mine.rawValue:
            return true
        case ReversedMemeGroup.Web.rawValue:
            return false
        default:
            assert(false, "Unexpected section")
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        switch section {
        case ReversedMemeGroup.Mine.rawValue:
            switch editingStyle {
            case .Delete:
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.memes.removeAtIndex(memes.count - 1 - indexPath.row)
                memes = appDelegate.memes
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                tableView.headerViewForSection(section)?.textLabel?.text = ReversedMemeGroups[section] + " (" + String(memesForGroup(section).count) + ")"
                
                appDelegate.shouldReloadCollectionView = true
                
                break
            default:
                break
            }
        default:
            assert(false, "Unexpected section")
        }
    }
    
    // MARK: Configure UI
    
    func configureCell(cell: MemeTableViewCell, withMeme meme: Meme) {
        print(meme.originalImagePath)
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(meme.originalImagePath) {
            let originalImage = UIImage(contentsOfFile: meme.originalImagePath)
            cell.memeImageView.image = originalImage
        }
        
        let attributes = Meme.previewTextAttributesForMeme(meme)
        cell.topLabel.attributedText = NSAttributedString(string: meme.topText, attributes: attributes)
        cell.topLabel.lineBreakMode = .ByTruncatingMiddle
        cell.bottomLabel.attributedText = NSAttributedString(string: meme.bottomText, attributes: attributes)
        cell.bottomLabel.lineBreakMode = .ByTruncatingMiddle
        cell.memeTextLabel.text = meme.topText + "..." + meme.bottomText
        cell.memeTextLabel.lineBreakMode = .ByTruncatingMiddle
        
        cell.dateLabel.text = Meme.stringFromDate(meme.sentDate)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowMemeDetail":
                if let detailVC = segue.destinationViewController as? MemeDetailViewController {
                    let memes = memesForGroup(tableView.indexPathForSelectedRow!.section)
                    detailVC.meme = memes[memes.count - 1 - tableView.indexPathForSelectedRow!.row]
                }
                return
            default:
                return
            }
        }
    }
    
    // MARK: Helper Methods
    
    func memesForGroup(group: Int) -> [Meme] {
        switch group {
        case ReversedMemeGroup.Mine.rawValue:
            return memes
        case ReversedMemeGroup.Web.rawValue:
            return localMemes
        default:
            assert(false, "Unknown date group type")
        }
    }
    
}

















