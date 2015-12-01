//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Display oldest items at the top
    private let localMemes: [Meme] = Meme.localMemes
    private var memes: [Meme]!
    
    private let MINIMUM_SPACING: CGFloat = 3.0
    private let NUMBER_OF_ITEMS_PER_LINE_PORTRAIT: Int = 3
    private let NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.minimumInteritemSpacing = MINIMUM_SPACING
        flowLayout.minimumLineSpacing = MINIMUM_SPACING
        flowLayout.itemSize = itemSize()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        memes = appDelegate.memes
        
        let section = MemeGroup.Mine.rawValue
        // Reload user created meme section if user deletes item(s) from table view
        if appDelegate.shouldReloadCollectionView! {
            collectionView!.reloadSections(NSIndexSet(index: section))
            appDelegate.shouldReloadCollectionView = false
        }
            // Otherwise, only update view(s) for newly created meme(s)
        else {
            let itemsCount = collectionView!.numberOfItemsInSection(section)
            if itemsCount < memes.count {
                var indexPaths = [NSIndexPath]()
                for item in itemsCount...(memes.count - 1) {
                    indexPaths.append(NSIndexPath(forItem: item, inSection: section))
                }
                collectionView!.insertItemsAtIndexPaths(indexPaths)
                let headerView = collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section)) as! MemeCollectionHeaderView
                headerView.titleLabel.text = MemeGroups[section] + " (" + String(memesForGroup(section).count) + ")"
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust item size when rotates
        flowLayout.itemSize = itemSize()
    }
    
    // MARK: Collection View Data Source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return MemeGroups.count
    }
    
    // Section header view
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MemeCollectionHeaderView", forIndexPath: indexPath) as! MemeCollectionHeaderView
            headerView.titleLabel.text = MemeGroups[indexPath.section] + " (" + String(memesForGroup(indexPath.section).count) + ")"
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memesForGroup(section).count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memesForGroup(indexPath.section)[indexPath.row]
        cell.setMeme(meme.originalImage, topText: meme.topText, bottomText: meme.bottomText, textAttributes: meme.textAttributes)
        
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
//        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
//        detailVC.meme = memesForGroup(indexPath.section)[indexPath.row]
//        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowMemeDetail":
                if let detailVC = segue.destinationViewController as? MemeDetailViewController {
                    let memes = memesForGroup((collectionView?.indexPathsForSelectedItems()![0].section)!)
                    detailVC.meme = memes[(collectionView?.indexPathsForSelectedItems()![0].row)!]
                }
                return
            default:
                return
            }
        }
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
    
    func memesForGroup(group: Int) -> [Meme] {
        switch group {
        case MemeGroup.Mine.rawValue:
            return memes
        case MemeGroup.Web.rawValue:
            return localMemes
        default:
            assert(false, "Unknown date group type")
        }
    }
    
}




















