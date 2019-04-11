//
//  MoveAdditionAcrossEquals.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Foundation

class MoveAdditionAcrossEquals: TransformationModel {
    init() {
        super.init(
            top: EqualsModel(
                PlusModel([PatternModel(0), WildcardModel()]),
                WildcardModel()),
            bottom: EqualsModel(
                WildcardModel(),
                PlusModel([NegativeModel(PatternModel(0)), WildcardModel()])))
    }
    
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        var mutMap = map
        if map.count == 1 {
            let one = mutMap.popFirst()!.value[0]
            if (type(of: one.getParent()!) == EqualsModel.self
                || (type(of: one.getParent()!) == PlusModel.self
                    // this is scary and bad and i shouln't do it this way
                    && type(of: one.getParent()!.getParent()!) == EqualsModel.self)) {
                return true
            }
        }
        
        return false
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        var lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        if let _ = lca.getParent() as? NegativeModel {
            lca = lca.getParent()!
        }
        
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
                    var newKids = [ExpressionModel]()
                    if lca.getChildIndex() > 0 {
                        newKids.append(contentsOf: plus.list[0...lca.getChildIndex() - 1])
                    }
                    if lca.getChildIndex() < plus.list.count - 1 {
                        newKids.append(contentsOf: plus.list[lca.getChildIndex() + 1...plus.list.count - 1])
                    }
                    newSelf = PlusModel(newKids)
                } else {
                    newSelf = plus.list[(lca.getChildIndex() + 1) % 2].orphanCopy()
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
                newOther = PlusModel([NegativeModel(lca.orphanCopy()), otherSide.orphanCopy()])
            }
            
            equals.replaceChildAt(lca.getChildIndex(), with: AtomicModel("0"))
            equals.replaceChildAt(otherSide.getChildIndex(), with: newOther)
        }
        
        return newExpression
    }
}
