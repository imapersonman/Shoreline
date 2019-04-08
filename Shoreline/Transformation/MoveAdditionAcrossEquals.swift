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
            if let _ = one.getParent() as? EqualsModel {
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
        } else if let parentAsEquals = lca.getParent() as? EqualsModel {
            let otherSide: ExpressionModel
            if lca.getChildIndex() == 0 {
                otherSide = parentAsEquals.right
            } else {
                otherSide = parentAsEquals.left
            }
            
            let newOther: ExpressionModel
            if let otherSideAsPlus = otherSide as? PlusModel {  // otherSide is a plus model
                var newOtherKids = [ExpressionModel]()  // ew, other kids
                if let lcaAsPlus = lca as? PlusModel {
                    newOtherKids = lcaAsPlus.list + otherSideAsPlus.list
                } else {
                    newOtherKids = [lca.orphanCopy()] + otherSideAsPlus.list
                }
                newOther = PlusModel(newOtherKids)
            } else {  // otherSide is something else
                newOther = PlusModel([NegativeModel(lca.orphanCopy()), otherSide.orphanCopy()])
            }
            
            parentAsEquals.replaceChildAt(lca.getChildIndex(), with: AtomicModel("0"))
            parentAsEquals.replaceChildAt(otherSide.getChildIndex(), with: newOther)
        }
        
        return newExpression
    }
}
