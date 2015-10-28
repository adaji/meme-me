//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController, MemeEditorViewDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Display oldest items at the top
    private let olderMemes: [Meme] = Meme.olderMemes
    private var latestMemes: [Meme]!
    
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
        
        latestMemes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
        // For better performance, only update view(s) for new meme(s)
        let section = DateGroup.Latest.rawValue
        let itemsCount = collectionView!.numberOfItemsInSection(section)
        if itemsCount < latestMemes.count {
            var indexPaths = [NSIndexPath]()
            for item in itemsCount...(latestMemes.count - 1) {
                indexPaths.append(NSIndexPath(forItem: item, inSection: section))
            }
            collectionView!.insertItemsAtIndexPaths(indexPaths)
            let headerView = collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section)) as! MemeCollectionHeaderView
            headerView.titleLabel.text = DateGroups[section] + " (" + String(memesForGroup(section).count) + ")"
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust item size when rotates
        flowLayout.itemSize = itemSize()
    }
    
    // MARK: Actions
    
    @IBAction func createMeme(sender: UIBarButtonItem) {
        let memeEditorVC = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        memeEditorVC.delegate = self
        
        presentViewController(memeEditorVC, animated: true, completion: nil)
    }
    
    // MARK: Collection View Data Source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return DateGroups.count
    }
    
    // Section header view
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MemeCollectionHeaderView", forIndexPath: indexPath) as! MemeCollectionHeaderView
            headerView.titleLabel.text = DateGroups[indexPath.section] + " (" + String(memesForGroup(indexPath.section).count) + ")"
            
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
        let memes = memesForGroup(indexPath.section)
        let meme = memes[indexPath.row]
        cell.setMeme(meme.originalImage, topText: meme.topText, bottomText: meme.bottomText, textAttributes: meme.textAttributes)
        
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = memesForGroup(indexPath.section)[indexPath.row]
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Meme Editor View Delegate
    
    func didSendMeme(meme: Meme) {
    }
    
    // MARK: Helper Methods
    
    // Adjust item size for different orientations
    func itemSize() -> CGSize {
        var dimension: CGFloat
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_PER_LINE_PORTRAIT - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_PER_LINE_PORTRAIT)
        }
        else {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_PER_LINE_LANDSCAPE)
        }
        
        return CGSizeMake(dimension, dimension)
    }
    
    func memesForGroup(group: Int) -> [Meme] {
        switch group {
        case DateGroup.Latest.rawValue:
            return latestMemes
        case DateGroup.Older.rawValue:
            return olderMemes
        default:
            assert(false, "Unknown date group type")
        }
    }
    
}




















