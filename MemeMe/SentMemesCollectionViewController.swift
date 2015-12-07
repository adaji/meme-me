//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit
import CoreData

class SentMemesCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
            try fetchedResultController.performFetch()
        } catch {
            print("Unresolved error: \(error)")
            abort()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView!.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust item size when rotates
        flowLayout.itemSize = itemSize()
    }
    
    // MARK: Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meme.Keys.SentDate, ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Section header view
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MemeCollectionHeaderView", forIndexPath: indexPath) as! MemeCollectionHeaderView
            headerView.titleLabel.text = "Sent Memes" + " (" + String(fetchedResultController.sections![indexPath.section].numberOfObjects) + ")"
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = fetchedResultController.objectAtIndexPath(indexPath) as! Meme
        configureCell(cell, withMeme: meme)
        
        return cell
    }
    
    func configureCell(cell: MemeCollectionViewCell, withMeme meme: Meme) {
        cell.memeImageView.image = Meme.imageWithName(meme.originalImageName)
        
        let attributes = Meme.previewTextAttributesForMeme(meme)
        cell.topLabel.attributedText = NSAttributedString(string: meme.topText, attributes: attributes)
        cell.topLabel.lineBreakMode = .ByTruncatingMiddle
        cell.bottomLabel.attributedText = NSAttributedString(string: meme.bottomText, attributes: attributes)
        cell.bottomLabel.lineBreakMode = .ByTruncatingMiddle
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = fetchedResultController.objectAtIndexPath(indexPath) as! Meme
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Helper Methods
    
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




















