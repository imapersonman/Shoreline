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

class IdentityTransformationModel: TransformationModel {
    let nAryOperator: NAryModel
    let identity: AtomicModel
    
    init(nAryOperator: NAryModel, identity: AtomicModel, top: ExpressionModel, bottom: ExpressionModel) {
        self.nAryOperator = nAryOperator
        self.identity = identity
        super.init(top: top, bottom: bottom)
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor(Set(map.values.joined())) ?? newExpression
        
        // don't lie i know you exist
        let parent = lca.getParent()!
        if let parentAsPlus = parent as? NAryModel, parentAsPlus.sameType(self.nAryOperator), parentAsPlus.list.count > 1 {  // if the parent is a plus view
            if lca.getChildIndex() < parentAsPlus.list.count - 1,
                let siblingAsAtom = parentAsPlus.list[lca.getChildIndex() + 1] as? AtomicModel,
                siblingAsAtom.text == self.identity.text {
                if parentAsPlus.list.count > 2 {
                    var newSiblings = [ExpressionModel]()
                    if lca.getChildIndex() > 0 {
                        newSiblings.append(contentsOf: parentAsPlus.list[0...lca.getChildIndex() - 1])
                    }
                    newSiblings.append(lca.orphanCopy())
                    if lca.getChildIndex() < parentAsPlus.list.count - 2 {
                        newSiblings.append(contentsOf: parentAsPlus.list[lca.getChildIndex() + 2...parentAsPlus.list.count - 1])
                    }
                    parentAsPlus.getParent()?.replaceChildAt(parentAsPlus.getChildIndex(), with: parentAsPlus.new(newSiblings))
                } else {
                    parentAsPlus.getParent()?.replaceChildAt(parentAsPlus.getChildIndex(), with: lca)
                }
            } else {
                var newSiblings = [ExpressionModel]()
                if lca.getChildIndex() > 0 {
                    newSiblings.append(contentsOf: parentAsPlus.list[0...lca.getChildIndex() - 1])
                }
                newSiblings.append(lca.orphanCopy())
                if lca.getChildIndex() < parentAsPlus.list.count - 1 {
                    newSiblings.append(contentsOf: parentAsPlus.list[lca.getChildIndex() + 1...parentAsPlus.list.count - 1])
                }
                parentAsPlus.replaceChildAt(parentAsPlus.getChildIndex(), with: parentAsPlus.new(newSiblings))
            }
        } else {  // the parent is not a plus view
            let newSelf = nAryOperator.new([lca.orphanCopy(), self.identity.orphanCopy()])
            parent.replaceChildAt(lca.getChildIndex(), with: newSelf)
        }
        
        return newExpression
    }
}

class MultiplicativeIdentityTransformationModel: IdentityTransformationModel {
    init() {
        // i shouldn't need the identity and top/bottom stuff, but time and abstraction and sleep
        // and whatever it's fine i promise it's just a little bit huffey to say people really is
        // the way they say they is or generally speaking not at all for the least of which even.
        super.init(
            nAryOperator: MultiplicationModel(),
            identity: AtomicModel("1"),
            top: MultiplicationModel([PatternModel(0), AtomicModel("1")]),
            bottom: PatternModel(0))
    }
}

class AdditiveIdentityTransformationModel: IdentityTransformationModel {
    init() {
        super.init(
            nAryOperator: PlusModel(),
            identity: AtomicModel("0"),
            top: PlusModel([PatternModel(0), AtomicModel("0")]),
            bottom: PatternModel(0))
    }
}

class CommutativeNAryTransformationModel: TransformationModel {
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
            if let asNAry = lca as? NAryModel {
                // the old one's like their mother better :(
                var ranges = Array(asNAry.selectedRanges.values)
                var middle = [ExpressionModel]()
                var firstIndex = 0
                var lastIndex = asNAry.list.count - 1
                if ranges[0].0 < ranges[1].0 {
                    firstIndex = ranges[0].0
                    middle.append(contentsOf: asNAry.list[ranges[1].0...ranges[1].1])
                    middle.append(contentsOf: asNAry.list[ranges[0].0...ranges[0].1])
                } else {
                    firstIndex = ranges[1].0
                    middle.append(contentsOf: asNAry.list[ranges[0].0...ranges[0].1])
                    middle.append(contentsOf: asNAry.list[ranges[1].0...ranges[1].1])
                }
                if ranges[0].1 > ranges[1].1 {
                    lastIndex = ranges[0].1
                } else {
                    lastIndex = ranges[1].1
                }
                var before = [ExpressionModel]()
                if firstIndex > 0 {
                    before.append(contentsOf: asNAry.list[0...firstIndex - 1])
                }
                var after = [ExpressionModel]()
                if lastIndex < asNAry.list.count - 1 {
                    after.append(contentsOf: asNAry.list[lastIndex + 1...asNAry.list.count - 1])
                }
                var newKids = before
                newKids.append(contentsOf: middle)
                newKids.append(contentsOf: after)
                let newPlus = asNAry.new(newKids)
                newPlus.selectedRanges = asNAry.selectedRanges
                lca.getParent()!.replaceChildAt(lca.getChildIndex(), with: newPlus)
                
                let newFirstPattern = newPlus.selectedRanges.popFirst()!
                let newSecondPattern = newPlus.selectedRanges.popFirst()!
                newPlus.selectedRanges[newFirstPattern.key] = newSecondPattern.value
                newPlus.selectedRanges[newSecondPattern.key] = newFirstPattern.value
            }
        }
        
        return newExpression
    }
}

// Everything will be specific until I have time to generalize
class CommutativeAdditionTransformationModel: CommutativeNAryTransformationModel {
    init() {
        super.init(
            top: PlusModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: PlusModel([PatternModel(1), PatternModel(0)] as [ExpressionModel]))
    }
}

// Everything will be specific until I have time to generalize
class CommutativeMultiplicationTransformationModel: CommutativeNAryTransformationModel {
    init() {
        super.init(
            top: MultiplicationModel([PatternModel(0), PatternModel(1)] as [ExpressionModel]),
            bottom: MultiplicationModel([PatternModel(1), PatternModel(0)] as [ExpressionModel]))
    }
}

class CommutativeEqualsTransformationModel: TransformationModel {
    init() {
        super.init(
            top: EqualsModel(PatternModel(0), PatternModel(1)),
            bottom: EqualsModel(PatternModel(1), PatternModel(0)))
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        let selectionTree = lca.toSelectionTree()
        
        if self.getMatchTuple(selectionTree) != nil {
            // guessing
            let one = map[0]!.first!
            let two = map[1]!.first!
            // orphan copy might not be necessary
            lca.replaceChildAt(one.getChildIndex(), with: two.orphanCopy())
            lca.replaceChildAt(two.getChildIndex(), with: one.orphanCopy())
            // swap selection indices.  this is all really gross and i'm not at all a fan of it.
            let newFirstPattern = lca.selectedRanges.popFirst()!
            let newSecondPattern = lca.selectedRanges.popFirst()!
            lca.selectedRanges[newFirstPattern.key] = newSecondPattern.value
            lca.selectedRanges[newSecondPattern.key] = newFirstPattern.value
        }
        
        return newExpression
    }
}

class DoubleNegativeTransformationModel: TransformationModel {
    init() {
        super.init(
            top: NegativeModel(NegativeModel(PatternModel(0))),
            bottom: PatternModel(0))
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        
        if map.count == 1 {
            if let parent1 = lca.getParent() as? NegativeModel {  // if there is a parent
                if let parent2 = parent1.getParent() as? NegativeModel {
                    parent2.getParent()?.replaceChildAt(parent2.getChildIndex(), with: lca.orphanCopy())
                }
            } else {
                // lca is an orphan.  return.
                lca.getParent()?.replaceChildAt(lca.getChildIndex(), with: NegativeModel(NegativeModel(lca.orphanCopy())))
            }
        }
        
        return newExpression
    }
}

class MoveAdditionAcrossEquals: TransformationModel {
    init() {
        super.init(
            top: EqualsModel(PlusModel([PatternModel(0), WildcardModel()]),
                             WildcardModel()),
            bottom: EqualsModel(WildcardModel(),
                                PlusModel([NegativeModel(PatternModel(0)), WildcardModel()])))
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        var lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        if let _ = lca.getParent() as? NegativeModel {
            lca = lca.getParent()!
        }
        
        if lca.getChildIndex() == 0 {  // if lca is on the left most side
            if let plus = lca.getParent() as? PlusModel {  // if lca parent is a plus
                if let equals = plus.getParent() as? EqualsModel {  // if lca parent's parent is an equals
                    let otherSide: ExpressionModel
                    if plus.getChildIndex() == 0 {
                        otherSide = equals.right
                    } else {
                        otherSide = equals.left
                    }
                    
                    let newSelf: ExpressionModel
                    let newOther: ExpressionModel
                    if let otherSideAsPlus = otherSide as? PlusModel {  // otherSide is a plus model
                        var newOtherKids = [ExpressionModel]()  // ew, other kids
                        newOtherKids.append(NegativeModel(lca.orphanCopy()))
                        newOtherKids.append(contentsOf: otherSideAsPlus.list)
                        newOther = PlusModel(newOtherKids)
                    } else {  // otherSide is something else
                        newOther = PlusModel([NegativeModel(lca.orphanCopy()), otherSide.orphanCopy()])
                    }
                    
                    if plus.list.count > 2 {
                        newSelf = PlusModel(Array(plus.list[1...plus.list.count - 1]))
                    } else {
                        newSelf = plus.list[1].orphanCopy()
                    }
                    
                    let newEquals = EqualsModel(ExpressionModel(), ExpressionModel())
                    newEquals.replaceChildAt(plus.getChildIndex(), with: newSelf)
                    newEquals.replaceChildAt(otherSide.getChildIndex(), with: newOther)
                    equals.getParent()?.replaceChildAt(equals.getChildIndex(), with: newEquals)
                }
            } else if let equals = lca.getParent() as? EqualsModel {  // if lca's parent is an equals
                // i don't think this case currently ever runs thanks to this useless selection model
                let otherSide: ExpressionModel
                if lca.getChildIndex() == 0 {
                    otherSide = equals.right
                } else {
                    otherSide = equals.left
                }
                
                // copy-paste
                let newOther: ExpressionModel
                if let otherSideAsPlus = otherSide as? PlusModel {  // otherSide is a plus model
                    var newOtherKids = [ExpressionModel]()  // ew, other kids
                    newOtherKids.append(NegativeModel(lca.orphanCopy()))
                    newOtherKids.append(contentsOf: otherSideAsPlus.list)
                    newOther = PlusModel(newOtherKids)
                } else {  // otherSide is something else
                    newOther = PlusModel([NegativeModel(lca.orphanCopy()), otherSide])
                }
                
                equals.replaceChildAt(lca.getChildIndex(), with: AtomicModel("0"))
                equals.replaceChildAt(otherSide.getChildIndex(), with: newOther)
            }
        }
        
        return newExpression
    }
}

class BottombarViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    var selectedModel: ExpressionModel?
    var quoteRealList = [
        CommutativeAdditionTransformationModel(),
        CommutativeMultiplicationTransformationModel(),
        // too bad to keep in for now
        AdditiveIdentityTransformationModel(),
        MultiplicativeIdentityTransformationModel(),
        CommutativeEqualsTransformationModel(),
        DoubleNegativeTransformationModel(),
        MoveAdditionAcrossEquals()
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
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let expression = self.selectedModel {
            let transformation = self.quoteRealList[indexPaths.first!.item]
            let transformedModel = transformation.transformExpression(expression)
            // should this be done in MainViewController or in here?
            transformedModel.clearSelectedRanges()
            self.selectedModel = transformedModel
            let dictionary = ["transformedModel": transformedModel]
            NotificationCenter.default.post(name: NSNotification.Name("transformationPressed"), object: self, userInfo: dictionary)
            collectionView.deselectItems(at: indexPaths)
            //self.selectedModel = nil
            print("transformationPressed has been something'd")
        } else {
            print("nothing selected")
        }
    }
}
