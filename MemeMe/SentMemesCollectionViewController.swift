//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import CoreData

class SentMemesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var deleteAllButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var selectedIndexPaths = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var isSelecting = false
    
    private let MINIMUM_SPACING: CGFloat = 3.0
    private let NUMBER_OF_ITEMS_PER_LINE_PORTRAIT: Int = 3
    private let NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE: Int = 5
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.minimumInteritemSpacing = MINIMUM_SPACING
        flowLayout.minimumLineSpacing = MINIMUM_SPACING
        flowLayout.itemSize = itemSize()
        
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
                
        collectionView!.reloadData()
        
        selectButton.enabled = fetchedResultsController.fetchedObjects?.count > 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust item size when rotates
        flowLayout.itemSize = itemSize()
    }
    
    // MARK: Actions
    
    @IBAction func selectButtonClicked(sender: UIBarButtonItem) {
        if sender.title == "Select" {
            // Enter selecting mode
            isSelecting = true
            configureUI(isSelecting)
        } else if sender.title == "Cancel" {
            // Cancel seleting
            isSelecting = false
            configureUI(isSelecting)
            
            cancelSelections()
        }
    }
    
    func configureUI(selecting: Bool) {
        if selecting {
            selectButton.title = "Cancel"
            addButton.enabled = false
            setBottomBarButtonsEnabled(false)
            tabBarController?.tabBar.hidden = true
            bottomBar.hidden = false
        } else {
            selectButton.title = "Select"
            addButton.enabled = true
            tabBarController?.tabBar.hidden = false
            bottomBar.hidden = true
        }
    }
    
    @IBAction func deleteAllMemes(sender: UIBarButtonItem) {
        for meme in fetchedResultsController.fetchedObjects as! [Meme] {
            sharedContext.deleteObject(meme)
        }
        saveContext()
        
        selectedIndexPaths = [NSIndexPath]()
        
        isSelecting = false
        configureUI(isSelecting)
    }
    
    @IBAction func deleteSelectedMemes(sender: UIBarButtonItem) {
        var memesToDelete = [Meme]()
        
        for indexPath in selectedIndexPaths {
            memesToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Meme)
        }
        
        for meme in memesToDelete {
            sharedContext.deleteObject(meme)
        }
        saveContext()
        
        selectedIndexPaths = [NSIndexPath]()
        
        isSelecting = false
        configureUI(isSelecting)
    }
    
    // Cancel all the seletions (display original images)
    func cancelSelections() {
        collectionView.reloadItemsAtIndexPaths(selectedIndexPaths)
        selectedIndexPaths = [NSIndexPath]()
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
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Meme object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Meme instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Meme instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // Core Data would notify us of changes if Meme instance is updated.
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            var selectedSections = Set<Int>()
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            for section in selectedSections {
                let sectionHeaderView = self.collectionView.viewWithTag(self.tagForSection(section)) as! MemeCollectionHeaderView
                sectionHeaderView.titleLabel.text = self.titleForSection(section)
            }
            
            }, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    // Section header view
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MemeCollectionHeaderView", forIndexPath: indexPath) as! MemeCollectionHeaderView
            headerView.tag = tagForSection(indexPath.section)
            headerView.titleLabel.text = titleForSection(indexPath.section)
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        if isSelecting {
            // Select Meme(s) to delete
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
            var selected: Bool
            if let index = selectedIndexPaths.indexOf(indexPath) {
                selectedIndexPaths.removeAtIndex(index)
                selected = false
            } else {
                selectedIndexPaths.append(indexPath)
                selected = true
            }
            
            cell.update(selected)
            
            updateBottomBar()
            
        } else {
            // Show Meme detail
            let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            detailVC.meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: Configure UI
    
    func configureCell(cell: MemeCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        
        cell.memeImageView.alpha = 1.0
        cell.memeImageView.image = Meme.imageWithName(meme.originalImageName)
        
        let attributes = Meme.previewTextAttributesForMeme(meme)
        cell.topLabel.attributedText = NSAttributedString(string: meme.topText, attributes: attributes)
        cell.topLabel.lineBreakMode = .ByTruncatingMiddle
        cell.bottomLabel.attributedText = NSAttributedString(string: meme.bottomText, attributes: attributes)
        cell.bottomLabel.lineBreakMode = .ByTruncatingMiddle
    }
    
    // If there is at least one selected item, enable bottom bar buttons
    // Otherwise, disable the buttons
    func updateBottomBar() {
        if selectedIndexPaths.count > 0 {
            setBottomBarButtonsEnabled(true)
        } else {
            setBottomBarButtonsEnabled(false)
        }
    }
    
    func setBottomBarButtonsEnabled(enabled: Bool) {
        deleteButton.enabled = enabled
    }
    
    // MARK: Helper Methods
    
    // Return tag value for section header view
    func tagForSection(section: Int) -> Int {
        return section + 1
    }
    
    // Return title for section header view
    func titleForSection(section: Int) -> String {
        return "Sent Memes" + " (" + String(fetchedResultsController.sections![section].numberOfObjects) + ")"
    }
    
    // Adjust item size for different orientations
    func itemSize() -> CGSize {
        var dimension: CGFloat
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_PER_LINE_PORTRAIT - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_PER_LINE_PORTRAIT)
        }
        else {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE)
        }
        
        return CGSizeMake(dimension, dimension)
    }
    
}




















