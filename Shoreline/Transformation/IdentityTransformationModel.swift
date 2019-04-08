//
//  IdentityTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class IdentityTransformationModel: TransformationModel {
    let nAryOperator: NAryModel
    let identity: AtomicModel
    
    init(nAryOperator: NAryModel, identity: AtomicModel, top: ExpressionModel, bottom: ExpressionModel) {
        self.nAryOperator = nAryOperator
        self.identity = identity
        super.init(top: top, bottom: bottom)
    }
    
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        if map.count != 1 {
            return false
        } else {
            return true
        }
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor(Set(map.values.joined())) ?? newExpression
        
        // don't lie i know you exist
        let parent = lca.getParent()!
        if let parentAsPlus = parent as? NAryModel,
            parentAsPlus.sameType(self.nAryOperator),
            parentAsPlus.list.count > 1 {
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
                newSiblings.append(self.identity.orphanCopy())
                if lca.getChildIndex() < parentAsPlus.list.count - 1 {
                    newSiblings.append(contentsOf: parentAsPlus.list[lca.getChildIndex() + 1...parentAsPlus.list.count - 1])
                }
                // scary
                parentAsPlus.getParent()!.replaceChildAt(parentAsPlus.getChildIndex(), with: parentAsPlus.new(newSiblings))
            }
        } else {
            let newSelf = nAryOperator.new([lca.orphanCopy(), self.identity.orphanCopy()])
            parent.replaceChildAt(lca.getChildIndex(), with: newSelf)
        }
        
        return newExpression
    }
}
