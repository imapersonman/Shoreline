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
    
    func getMatchTuple(_ selectedTree: ExpressionModel) -> (ExpressionModel, ExpressionModel)? {
        if selectedTree.matchesExpression(self.top) {
            return (self.top, self.bottom)
        } else if selectedTree.matchesExpression(self.bottom) {
            return (self.bottom, self.top)
        } else {
            return nil
        }
    }
    
    func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        return expression
    }
}

class CommutativeTransformationModel: TransformationModel {
    init() {
        super.init(
            top: PlusModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: PlusModel([PatternModel(1), PatternModel(0)] as [ExpressionModel]))
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        let selectionTree = lca.toSelectionTree()
        
        if self.getMatchTuple(selectionTree) != nil {
            // this is where it all gets really gross
            // selectionTree should be a '+' node at this point. so imma take advantage of that
            // selectionTree also contains exactly two patterns, and they are adjacent to each other
            // not general at all
            if let asPlus = lca as? PlusModel {
                // the old one's like their mother better :(
                var ranges = Array(asPlus.selectedRanges.values)
                var middle = [ExpressionModel]()
                var firstIndex = 0
                var lastIndex = asPlus.list.count - 1
                if ranges[0].0 < ranges[1].0 {
                    firstIndex = ranges[0].0
                    middle.append(contentsOf: asPlus.list[ranges[1].0...ranges[1].1])
                    middle.append(contentsOf: asPlus.list[ranges[0].0...ranges[0].1])
                } else {
                    firstIndex = ranges[1].0
                    middle.append(contentsOf: asPlus.list[ranges[0].0...ranges[0].1])
                    middle.append(contentsOf: asPlus.list[ranges[1].0...ranges[1].1])
                }
                if ranges[0].1 > ranges[1].1 {
                    lastIndex = ranges[0].1
                } else {
                    lastIndex = ranges[1].1
                }
                var before = [ExpressionModel]()
                if firstIndex > 0 {
                    before.append(contentsOf: asPlus.list[0...firstIndex - 1])
                }
                var after = [ExpressionModel]()
                if lastIndex < asPlus.list.count - 1 {
                    after.append(contentsOf: asPlus.list[lastIndex + 1...asPlus.list.count - 1])
                }
                var newKids = before
                newKids.append(contentsOf: middle)
                newKids.append(contentsOf: after)
                let newPlus = PlusModel(newKids)
                lca.getParent()!.replaceChildAt(lca.getChildIndex(), with: newPlus)
            }
        }
        
        return newExpression
    }
}

class BottombarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var selectedModel: ExpressionModel?
    var quoteRealList = [
        CommutativeTransformationModel()
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
            self.selectedModel = selection
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
    
    func findMatchingSelectedSubtree(_ expression: ExpressionModel, _ pattern: ExpressionModel) -> ExpressionModel? {
        return expression  // FOR NOWW!!!!
    }
    
    func transformExpression(_ expression: ExpressionModel, _ transformation: TransformationModel) -> ExpressionModel {
        /*
         * New Approach:
         * 1) make map through depth first search of expression, associating selected node's selectionIndex with
         *    the selection node itself
         * 2) find least common ancestor of selected nodes, if matches one side of transform, transform
         * 3) replace least common ancestor with transform
         */
        /*
        let newExpression = SourceModel(expression.orphanCopy())
        let map = newExpression.createPatternMap()
        
        if let lca = ExpressionModel.lowestCommonAncestor(Set(map.values.joined())) {
            let selectionTree = lca.toSelectionTree()
            if selectionTree.matchesExpression(transformation.top) {
                let replacement = transformation.bottom.orphanCopy()
                replacement.applyPatternMap(map)
                lca.getParent()!.replaceChildAtIndex(lca.getChildIndex(), with: replacement)
                return newExpression
            } else if lca.matchesExpression(transformation.bottom) {
                
            } else {
                
            }
        } else {
            return expression
        }
        
        return expression
         */
        return transformation.transformExpression(expression)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let expression = self.selectedModel {
            let transformation = self.quoteRealList[indexPaths.first!.item]
            let transformedModel = self.transformExpression(expression, transformation)
            let dictionary = ["transformedModel": transformedModel]
            NotificationCenter.default.post(name: NSNotification.Name("transformationPressed"), object: self, userInfo: dictionary)
            collectionView.deselectItems(at: indexPaths)
            print("transformationPressed has been something'd")
        } else {
            print("nothing selected")
        }
    }
}
