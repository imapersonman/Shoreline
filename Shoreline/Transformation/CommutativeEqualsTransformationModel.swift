//
//  CommutativeEqualsTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class CommutativeEqualsTransformationModel: TransformationModel {
    init() {
        super.init(
            top: EqualsModel(PatternModel(0), PatternModel(1)),
            bottom: EqualsModel(PatternModel(1), PatternModel(0)))
    }
    
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        var mutMap = map
        if mutMap.count == 2 {
            let oneParent = mutMap.popFirst()!.value[0].getParent()!
            let twoParent = mutMap.popFirst()!.value[0].getParent()!
            if oneParent == twoParent, let _ = oneParent as? EqualsModel {
                return true
            }
        }
        
        return false
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        var map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        let selectionTree = lca.toSelectionTree()
        
        if self.getMatchTuple(selectionTree) != nil {
            // guessing
            let one = map.popFirst()!.value.first!
            let two = map.popFirst()!.value.first!
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
