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
    var selectedModel: ExpressionModel?
    var quoteRealList = [
        CommutativeEqualsTransformationModel(),
        CommutativeAdditionTransformationModel(),
        CommutativeMultiplicationTransformationModel(),
        AdditiveIdentityTransformationModel(),
        MultiplicativeIdentityTransformationModel(),
        DoubleNegativeTransformationModel(),
        MoveAdditionAcrossEquals(),
        MoveMultiplicationAcrossEquals()
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
    
    @objc func filterTransformations(_ notification: NSNotification) {
        if let selection = notification.userInfo?["selection"] as? ExpressionModel {
            self.selectedModel = selection
            /*
            let map = selectedModel?.createPatternMap()
            for transformation in quoteRealList {
                transformation.setLocked(!transformation.matchesExpressionMap(map!))
            }
             */
            //self.collectionView.reloadData()
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
        item.lockTransformation(transformation.getLocked())
        return item
    }
    
    func findMatchingSelectedSubtree(_ expression: ExpressionModel, _ pattern: ExpressionModel) -> ExpressionModel? {
        return expression  // FOR NOWW!!!!
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let expression = self.selectedModel {
            let transformation = self.quoteRealList[indexPaths.first!.item]
            if transformation.getLocked() {
                return
            }
            let transformedModel = transformation.transformExpression(expression)
            /*
            for transformation in quoteRealList {
                transformation.setLocked(true)
            }
             */
            self.collectionView.reloadData()
            // should this be done in MainViewController or in here?
            transformedModel.clearSelectedRanges()
            self.selectedModel = transformedModel
            let dictionary = ["transformedModel": transformedModel]
            NotificationCenter.default.post(name: NSNotification.Name("transformationPressed"), object: self, userInfo: dictionary)
            collectionView.deselectItems(at: indexPaths)
        }
    }
}
