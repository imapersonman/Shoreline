//
//  SidebarViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var fakeList = [String]();
    
    static let ARBITRARY_ITEM_HEIGHT = 50.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.collectionView.register(SidebarItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"))
        
        /*
        let layout = NSCollectionViewGridLayout()
        layout.maximumNumberOfColumns = 1
        layout.maximumItemSize = NSSize(width: 0.0, height: SidebarViewController.ARBITRARY_ITEM_HEIGHT)
        layout.minimumItemSize = NSSize(width: 0.0, height: SidebarViewController.ARBITRARY_ITEM_HEIGHT)
        self.collectionView.collectionViewLayout = layout
         */
    }
    
    var plus = 1;
    @IBAction func plusButtonPressed(_ sender: Any) {
        self.fakeList.append("Expression \(plus)");
        self.plus = self.plus + 1;
        self.collectionView.reloadData();
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fakeList.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = self.collectionView.makeItem(withIdentifier:NSUserInterfaceItemIdentifier(rawValue: "reuseId"), for: indexPath) as! SidebarItem;
        item.setLabelText(text: self.fakeList[indexPath.item]);
        return item;
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        // I like to live dangerously...
        let dictionary = ["text": self.fakeList[indexPaths.first!.item]];
        NotificationCenter.default.post(name: NSNotification.Name("expressionSelected"), object: self, userInfo: dictionary)
    }
}
