//
//  RemoveOneInDenominator.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/11/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

class RemoveOneInDenominator: TransformationModel {
    init() {
        super.init(
            top: RationalModel(PatternModel(0), AtomicModel("1")),
            bottom: PatternModel(0))
    }
    
    override func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        return map.count == 1
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor(Set(map.values.joined())) ?? newExpression
        
        if let lcaParent = lca.getParent() as? RationalModel,
            lca.getChildIndex() == 0,  // in te num
            let den = lcaParent.denominator as? AtomicModel,
            den.text == "1" {
            
            if let parentParent = lcaParent.getParent() as? NAryModel,
                let lcaAsNAry = lca as? NAryModel,
                parentParent.sameType(lcaAsNAry) {
                var newKids = [ExpressionModel]()
                if lcaParent.getChildIndex() == 0 {
                    newKids += lcaAsNAry.list + parentParent.list[1...]
                } else if lcaParent.getChildIndex() == parentParent.list.count - 1 {
                    newKids += parentParent.list[...(lcaParent.getChildIndex() - 1)] + lcaAsNAry.list
                } else {
                    newKids += parentParent.list[...(lcaParent.getChildIndex() - 1)]
                        + lcaAsNAry.list + parentParent.list[(lcaParent.getChildIndex() + 1)...]
                }
                parentParent.getParent()!.replaceChildAt(parentParent.getChildIndex(),with: parentParent.new(newKids))
            } else {
                if let lcaAsMult = lca as? NAryModel {
                    if lca.selectedRanges.isEmpty {
                        lcaParent.getParent()!.replaceChildAt(lcaParent.getChildIndex(), with: lca.orphanCopy())
                    } else {
                        let range = lca.selectedRanges.first!.value
                        let newKids: [ExpressionModel]
                        
                        // assuming the range does not cover the list...
                        if range.0 == 0 {
                            newKids = lcaAsMult.list[...range.1]
                                + [RationalModel(MultiplicationModel(Array(lcaAsMult.list[(range.1 + 1)...])), AtomicModel("1"))]
                        } else if range.1 == lcaAsMult.list.count - 1 {
                            newKids = [RationalModel(MultiplicationModel(Array(lcaAsMult.list[...(range.0 - 1)])), AtomicModel("1"))]
                                + lcaAsMult.list[range.0...]
                        } else {
                            newKids = [RationalModel(MultiplicationModel(Array(lcaAsMult.list[...(range.0 - 1)])), AtomicModel("1"))]
                                + lcaAsMult.list[range.0...range.1]
                                + [RationalModel(MultiplicationModel(Array(lcaAsMult.list[(range.1 + 1)...])), AtomicModel("1"))]
                        }
                        
                        lcaParent.getParent()?.replaceChildAt(lcaParent.getChildIndex(), with: MultiplicationModel(newKids))
                    }
                } else {
                    lcaParent.getParent()!.replaceChildAt(lcaParent.getChildIndex(), with: lca)
                }
            }
        } else {
            if let lcaAsMult = lca as? NAryModel {
                if !lca.selectedRanges.isEmpty {
                    // cuz assuming one selection
                    let range = lca.selectedRanges.first!.value  // aaahhh
                    var multKids = [ExpressionModel]()
                    let ratKids = [ExpressionModel](lcaAsMult.list[range.0...range.1])  // no one ever wanted to play with them
                    if range.0 > 0 {
                        multKids += Array(lcaAsMult.list[0...range.0 - 1])
                    }
                    multKids.append(RationalModel(lcaAsMult.new(ratKids), AtomicModel("1")))
                    if range.1 < lcaAsMult.list.count - 1 {
                        multKids += Array(lcaAsMult.list[range.1 + 1...lcaAsMult.list.count - 1])
                    }
                    lca.getParent()!.replaceChildAt(lca.getChildIndex(), with: lcaAsMult.new(multKids))
                    return newExpression  // nooooo don't do ittttttt
                }
                let replacement = RationalModel(lca.orphanCopy(), AtomicModel("1"))
                lca.getParent()!.replaceChildAt(lca.getChildIndex(), with: replacement)
            } else {
                let replacement = RationalModel(lca.orphanCopy(), AtomicModel("1"))
                lca.getParent()!.replaceChildAt(lca.getChildIndex(), with: replacement)
            }
        }
        
        return newExpression
    }
}
