//
//  MoveMultiplicationAcrossEquals.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Foundation

class MoveMultiplicationAcrossEquals: TransformationModel {
    init() {
        super.init(
            top: EqualsModel(
                MultiplicationModel([PatternModel(0), WildcardModel()]),
                WildcardModel()),
            bottom: EqualsModel(
                WildcardModel(),
                RationalModel(WildcardModel(), PatternModel(0))))
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
        
        if let parentAsMult = lca.getParent() as? MultiplicationModel {
            if lca.getChildIndex() != 0 {
                return newExpression
            }
            
            if let equals = parentAsMult.getParent() as? EqualsModel {
                let otherSide: ExpressionModel
                if parentAsMult.getChildIndex() == 0 {
                    otherSide = equals.right
                } else {
                    otherSide = equals.left
                }
                
                let newThisSide: ExpressionModel
                let newOtherSide: ExpressionModel
                
                if let otherAsDiv = otherSide as? RationalModel {
                    if let otherDenAsMult = otherAsDiv.denominator as? MultiplicationModel {
                        newOtherSide = RationalModel(
                            otherAsDiv.numerator.orphanCopy(),
                            MultiplicationModel([lca.orphanCopy()] + otherDenAsMult.list.map({ (child) in child.orphanCopy() })))
                    } else {
                        newOtherSide = RationalModel(
                            otherAsDiv.numerator.orphanCopy(),
                            MultiplicationModel([lca.orphanCopy(), otherAsDiv.denominator.orphanCopy()]))
                    }
                } else {
                    newOtherSide = RationalModel(otherSide.orphanCopy(), lca.orphanCopy())
                }
                
                if parentAsMult.list.count == 2 {
                    newThisSide = parentAsMult.list[(lca.getChildIndex() + 1) % 2].orphanCopy()
                } else {
                    // assuming parentAsMult.list.count != 1 (dangerous)
                    newThisSide = MultiplicationModel(Array(parentAsMult.list[1...parentAsMult.list.count - 1]))
                }
                
                equals.replaceChildAt(parentAsMult.getChildIndex(), with: newThisSide)
                equals.replaceChildAt(otherSide.getChildIndex(), with: newOtherSide)
            }
        } else if let parentAsDiv = lca.getParent() as? RationalModel {
            if lca.getChildIndex() != 1 {
                return newExpression
            }
            if let equals = parentAsDiv.getParent() as? EqualsModel {
                let otherSide: ExpressionModel
                if parentAsDiv.getChildIndex() == 0 {
                    otherSide = equals.right
                } else {
                    otherSide = equals.left
                }
                
                let newThisSide: ExpressionModel
                let newOtherSide: ExpressionModel
                
                newThisSide = parentAsDiv.numerator.orphanCopy()
                
                if let otherAsMult = otherSide as? MultiplicationModel {
                    var newKids = [lca.orphanCopy()]
                    newKids.append(contentsOf: otherAsMult.list)
                    newOtherSide = MultiplicationModel(newKids)
                } else {
                    newOtherSide = MultiplicationModel([lca.orphanCopy(), otherSide.orphanCopy()])
                }
                
                equals.replaceChildAt(parentAsDiv.getChildIndex(), with: newThisSide)
                equals.replaceChildAt(otherSide.getChildIndex(), with: newOtherSide)
            }
        } else if let equals = lca.getParent() as? EqualsModel {
            let otherSide: ExpressionModel
            if lca.getChildIndex() == 0 {
                otherSide = equals.right
            } else {
                otherSide = equals.left
            }
            
            let newThisSide: ExpressionModel
            let newOtherSide: ExpressionModel
            
            newThisSide = AtomicModel("1")
            
            if let otherAsDiv = otherSide as? RationalModel {
                if let otherDenAsMult = otherAsDiv.denominator as? MultiplicationModel {
                    newOtherSide = RationalModel(
                        otherAsDiv.numerator.orphanCopy(),
                        MultiplicationModel([lca.orphanCopy()] + otherDenAsMult.list.map({ (child) in child.orphanCopy() })))
                } else {
                    newOtherSide = RationalModel(
                        otherAsDiv.numerator.orphanCopy(),
                        MultiplicationModel([lca.orphanCopy(), otherAsDiv.denominator.orphanCopy()]))
                }
            } else {
                newOtherSide = RationalModel(otherSide.orphanCopy(), lca.orphanCopy())
            }
            
            equals.replaceChildAt(lca.getChildIndex(), with: newThisSide)
            equals.replaceChildAt(otherSide.getChildIndex(), with: newOtherSide)
        }
        
        return newExpression
    }
}
