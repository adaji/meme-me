//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ada Ji on 10/27/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    var memes: [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
        collectionView!.reloadData()
    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        cell.setMeme(meme.image, top: meme.top, bottom: meme.bottom, attributes: meme.attributes)
        
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailVC, animated: true)
    }

}











