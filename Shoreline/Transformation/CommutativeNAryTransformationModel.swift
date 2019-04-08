//
//  CommutativeNAryTransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class CommutativeNAryTransformationModel: TransformationModel {
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        var mutMap = map
        if mutMap.count == 2 {
            let oneParent = mutMap.popFirst()!.value[0].getParent()!
            let twoParent = mutMap.popFirst()!.value[0].getParent()!
            if oneParent == twoParent, let parent = oneParent as? NAryModel {
                return parent.sameType(self.top as! NAryModel)
            }
        }
        
        return false
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
