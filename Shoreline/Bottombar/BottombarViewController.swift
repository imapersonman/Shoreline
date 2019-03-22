//
//  BottombarViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class BottombarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var fakeList = [String]()
    
    static let ARBITRARY_ITEM_HEIGHT = 100.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here
        self.collectionView.register(
            BottombarItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"));
        for index in 1...34 {
            fakeList.append(String(index))
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fakeList.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = self.collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("reuseId"),
            for: indexPath) as! BottombarItem;
        item.setLabelText(text: self.fakeList[indexPath.item]);
        return item;
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        // Something is weird about this.  Figure it out
        let dictionary = ["text": self.fakeList[indexPaths.first!.item]]
        NotificationCenter.default.post(name: NSNotification.Name("transformationPressed"), object: self, userInfo: dictionary)
        self.collectionView.deselectAll(nil);
    }
}
