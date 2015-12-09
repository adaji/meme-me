//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import CoreData

// MARK: - SentMemesTableViewController: UITableViewController

class SentMemesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.userInteractionEnabled = true
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error: \(error)")
            abort()
        }
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meme.Keys.SentDate, ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sent Memes" + " (" + String(fetchedResultsController.sections![section].numberOfObjects) + ")"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")! as! MemeTableViewCell
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        configureCell(cell, withMeme: meme)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let memeDetailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        memeDetailVC.meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        
        navigationController!.pushViewController(memeDetailVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
            sharedContext.deleteObject(meme)
            saveContext()
        default:
            break
        }
    }
    
    // MARK: Configure UI
    
    func configureCell(cell: MemeTableViewCell, withMeme meme: Meme) {
        cell.memeImageView.image = Meme.imageWithName(meme.originalImageName)
        
        let attributes = Meme.previewTextAttributesForMeme(meme)
        cell.topLabel.attributedText = NSAttributedString(string: meme.topText, attributes: attributes)
        cell.topLabel.lineBreakMode = .ByTruncatingMiddle
        cell.bottomLabel.attributedText = NSAttributedString(string: meme.bottomText, attributes: attributes)
        cell.bottomLabel.lineBreakMode = .ByTruncatingMiddle
        cell.memeTextLabel.text = meme.topText + "..." + meme.bottomText
        cell.memeTextLabel.lineBreakMode = .ByTruncatingMiddle
        
        cell.dateLabel.text = Meme.stringFromDate(meme.sentDate)
    }
    
}

















