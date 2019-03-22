//
//  ViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/9/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {

    @IBOutlet weak var transformationView: NSCollectionView!
    let fakeList1 = ["Neither", "is", "this", "but", "is", "it?", "no"];
    
    @IBOutlet weak var sidebar: NSCollectionView!
    let fakeList2 = ["This", "List", "Is", "Not", "Real"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.transformationView.delegate = self;
        self.transformationView.dataSource = self;
        self.transformationView.register(TransformationItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"));
        
        self.sidebar.delegate = self;
        self.sidebar.dataSource = self;
        self.sidebar.register(SidebarItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"));
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeList2.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // dangerous.
        let item = self.sidebar.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("reuseId"), for: indexPath) as! SidebarItem;
        item.labelField.stringValue = self.fakeList2[indexPath.item];
        item.view.layer?.backgroundColor = CGColor.black;
        return item;
    }

}

