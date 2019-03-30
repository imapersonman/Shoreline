//
//  BottombarViewController.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class TransformationModel {
    let top: ExpressionModel
    let bottom: ExpressionModel
    
    init(top: ExpressionModel, bottom: ExpressionModel) {
        self.top = top
        self.bottom = bottom
    }
}

class BottombarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var fakeList = [String]()
    var quoteRealList = [
        TransformationModel(
            top: PlusModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: PlusModel([PatternModel(1), PatternModel(0)] as [ExpressionModel])),
        TransformationModel(
            top: RationalModel(PatternModel(0), PatternModel(1)),
            bottom: RationalModel(PatternModel(1), PatternModel(0))),
    ]
    
    static let ARBITRARY_ITEM_HEIGHT = 100.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here
        self.collectionView.register(
            BottombarItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("reuseId"))
        NotificationCenter.default.addObserver(self,
            selector: #selector(filterTransformations(_:)),
            name: NSNotification.Name("filterTransformations"),
            object: nil)
    }
    
    var something = 0
    @objc func filterTransformations(_ notification: NSNotification) {
        if let selection = notification.userInfo?["selection"] as? ExpressionModel {
            //print("stuff recievedL \(something)")
            self.something += 1
        } else {
            print("You LIED to me about what you gave me, I'm filter transformations")
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.quoteRealList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = self.collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("reuseId"),
            for: indexPath) as! BottombarItem
        let transformation = self.quoteRealList[indexPath.item]
        item.setExpressions(top: transformation.top, bottom: transformation.bottom)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        // Something is weird about this.  Figure it out
        /*
        let dictionary = ["text": "yeah this is text"/*self.fakeList[indexPaths.first!.item]*/]
        NotificationCenter.default.post(name: NSNotification.Name("transformationPressed"), object: self, userInfo: dictionary)
        self.collectionView.deselectAll(nil);
         */
    }
}
