//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController, MemeEditorViewControllerDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme]!
    
    private let MINIMUM_SPACING: CGFloat = 3.0
    private let NUMBER_OF_ITEMS_IN_PORTRAIT_LINE: Int = 3
    private let NUMBER_OF_ITEMS_IN_LANDSCAPE_LINE: Int = 5
    
    private var hasNewMemeToDisplay: Bool!
    
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
        
        flowLayout.minimumInteritemSpacing = MINIMUM_SPACING
        flowLayout.minimumLineSpacing = MINIMUM_SPACING
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        hasNewMemeToDisplay = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // For better performance, insert new meme at the end
        if (hasNewMemeToDisplay!) {
            collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: collectionView!.numberOfItemsInSection(0), inSection: 0)])
            hasNewMemeToDisplay = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Adjust item size when rotates
        var dimension: CGFloat
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_IN_PORTRAIT_LINE - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_IN_PORTRAIT_LINE)
        }
        else {
            dimension = (self.view.frame.size.width - CGFloat(NUMBER_OF_ITEMS_IN_LANDSCAPE_LINE - 1) * MINIMUM_SPACING) / CGFloat(NUMBER_OF_ITEMS_IN_LANDSCAPE_LINE)
        }
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    // MARK: Collection View Data Source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dateGroups.count
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MemeCollectionHeaderView", forIndexPath: indexPath) as! MemeCollectionHeaderView
            headerView.titleLabel.text = dateGroups[indexPath.section]
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? memes.count : 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        cell.setMeme(meme.originalImage, topText: meme.topText, bottomText: meme.bottomText, textAttributes: meme.textAttributes)
        
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    // Adjust item size when screen rotates
    func screenDidRotate() {
        let space: CGFloat = 3.0
        var dimension: CGFloat
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
            dimension = (self.view.frame.size.width - 2 * space) / 3.0
        }
        else {
            dimension = (self.view.frame.size.width - 2 * space) / 5.0
        }
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
}




















