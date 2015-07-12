//
//  UsersController.swift
//  CloudKitManager
//
//  Created by engineering on 6/7/15.
//  Copyright (c) 2015 magicpoint. All rights reserved.
//

import UIKit

class UserController: UIViewController,
UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var mainCollectionView: UICollectionView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("%@: %@", reflect(self).summary, __FUNCTION__)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCellID", forIndexPath: indexPath) as! UICollectionViewCell
        return collectionViewCell
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: IBAction
    
    @IBAction func dismissController(sender: AnyObject) {
        NSLog("%@", __FUNCTION__)
        self.dismissViewControllerAnimated(true, completion: {
        })
    }
}