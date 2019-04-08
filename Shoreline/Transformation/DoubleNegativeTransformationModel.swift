//
//  DoubleNegativeTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class DoubleNegativeTransformationModel: TransformationModel {
    init() {
        super.init(
            top: NegativeModel(NegativeModel(PatternModel(0))),
            bottom: PatternModel(0))
    }
    
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        return map.count == 1
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
