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
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? ExpressionModel()
        
        if map.count != 1 {
            return false
        }
        
        
        if let lcaParent = lca.getParent() as? EqualsModel {
            return true
        } else if let lcaParent = lca.getParent() as? MultiplicationModel {
            if let parentParent = lcaParent.getParent() as? EqualsModel {
                return true
            } else if let parentParent = lcaParent.getParent() as? RationalModel {
                if let _ = parentParent.getParent() as? EqualsModel {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else if let lcaParent = lca.getParent() as? RationalModel {
            if let _ = lcaParent.getParent() as? EqualsModel {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    override func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        let newExpression = expression.orphanCopy()
        let map = newExpression.createPatternMap()
        let lca = ExpressionModel.lowestCommonAncestor((Set(map.values.joined()))) ?? newExpression
        
        var equals: EqualsModel = EqualsModel(AtomicModel("1"), AtomicModel("-1111"))
        var thisSide: ExpressionModel = ExpressionModel()
        var otherSide: ExpressionModel = ExpressionModel()
        
        var newThisSide: ExpressionModel = ExpressionModel()
        var newOtherSide: ExpressionModel = ExpressionModel()
        
        var inNumerator: Bool = true
        
        // determine newThisSide
        if let lcaParent = lca.getParent() as? EqualsModel {
            equals = lcaParent
            thisSide = lca
            
            if let lcaAsMult = lca as? MultiplicationModel, !lcaAsMult.selectedRanges.isEmpty {
                var newThisKids = [ExpressionModel]()
                let range = lcaAsMult.selectedRanges.first!.value  // aaahhhhhh
                if range.0 > 0 {
                    newThisKids.append(contentsOf: lcaAsMult.list[0...range.0 - 1])
                }
                if range.1 < lcaAsMult.list.count - 1 {
                    newThisKids.append(contentsOf: lcaAsMult.list[range.1 + 1...lcaAsMult.list.count - 1])
                }
                newThisSide = MultiplicationModel(newThisKids)
            } else {
                newThisSide = AtomicModel("1")
            }
        } else if let lcaParent = lca.getParent() as? MultiplicationModel {
            var newThisKids = [ExpressionModel]()
            if lca.getChildIndex() > 0 {
                newThisKids.append(contentsOf: lcaParent.list[0...lca.getChildIndex() - 1])
            }
            if lca.getChildIndex() < lcaParent.list.count - 1 {
                newThisKids.append(contentsOf: lcaParent.list[lca.getChildIndex() + 1...lcaParent.list.count - 1])
            }
            if let parentParent = lcaParent.getParent() as? EqualsModel {
                equals = parentParent
                thisSide = lcaParent
                newThisSide = MultiplicationModel(newThisKids)
            } else if let parentParent = lcaParent.getParent() as? RationalModel {
                if let parentParentParent = parentParent.getParent() as? EqualsModel {  // this is disgusting
                    equals = parentParentParent
                    thisSide = parentParent
                    
                    inNumerator = lcaParent.getChildIndex() == 0
                    if inNumerator {
                        newThisSide = RationalModel(MultiplicationModel(newThisKids), parentParent.denominator)
                    } else {
                        newThisSide = RationalModel(parentParent.numerator, MultiplicationModel(newThisKids))
                    }
                } else {
                    return newExpression
                }
            } else {
                return newExpression
            }
        } else if let lcaParent = lca.getParent() as? RationalModel {
            if let parentParent = lcaParent.getParent() as? EqualsModel {
                equals = parentParent
                thisSide = lcaParent
                
                inNumerator = lca.getChildIndex() == 0
                if inNumerator {
                    // refactor!
                    if let lcaAsMult = lca as? MultiplicationModel, !lcaAsMult.selectedRanges.isEmpty {
                        var newThisKids = [ExpressionModel]()
                        let range = lca.selectedRanges.first!.value
                        if range.0 > 0 {
                            newThisKids.append(contentsOf: lcaAsMult.list[0...range.0 - 1])
                        }
                        if range.1 < lcaAsMult.list.count - 1 {
                            newThisKids.append(contentsOf: lcaAsMult.list[range.1 + 1...lcaAsMult.list.count - 1])
                        }
                        newThisSide = RationalModel(MultiplicationModel(newThisKids), lcaParent.denominator)
                    } else {
                        newThisSide = RationalModel(AtomicModel("1"), lcaParent.denominator)
                    }
                } else {
                    // should be different if lca is multiplication (which i thought i checked for but k)
                    if let lcaAsMult = lca as? MultiplicationModel, !lcaAsMult.selectedRanges.isEmpty {
                        let range = lca.selectedRanges.first!.value
                        var newThisKids = [ExpressionModel]()
                        if range.0 > 0 {
                            newThisKids.append(contentsOf: lcaAsMult.list[0...range.0 - 1])
                        }
                        if range.1 < lcaAsMult.list.count - 1 {
                            newThisKids.append(contentsOf: lcaAsMult.list[range.1 + 1...lcaAsMult.list.count - 1])
                        }
                        newThisSide = RationalModel(lcaParent.numerator, MultiplicationModel(newThisKids))
                    } else {
                        newThisSide = RationalModel(lcaParent.numerator, AtomicModel("1"))
                    }
                }
            } else {
                return newExpression
            }
        }
        
        if thisSide.getChildIndex() == 0 {
            otherSide = equals.right
        } else {
            otherSide = equals.left
        }
        
        if let otherAsMult = otherSide as? MultiplicationModel, !inNumerator {  // if in numerator, go to else
            var newNumKids = [ExpressionModel]()
            if let lcaAsMult = lca as? MultiplicationModel, lca.selectedRanges.count > 0 {
                let range = lcaAsMult.selectedRanges.first!.value
                newNumKids = Array(lcaAsMult.list[range.0...range.1])
            } else {
                newNumKids = [lca.orphanCopy()]
            }
            newNumKids += otherAsMult.list.map({ model in model.orphanCopy() })
            newOtherSide = MultiplicationModel(newNumKids)
        } else if let otherAsDiv = otherSide as? RationalModel {
            if inNumerator {
                var newDenKids = [ExpressionModel]()
                // this is to get rid of a bug, but it may introduce others (yay!)
                if let lcaAsMult = lca as? NAryModel/*MultiplicationModel*/ {
                    if lca.selectedRanges.isEmpty {
                        newDenKids = lcaAsMult.list
                    } else {
                        let range = lcaAsMult.selectedRanges.first!.value
                        newDenKids = Array(lcaAsMult.list[range.0...range.1])
                    }
                } else {
                    newDenKids = [lca.orphanCopy()]
                }
                newDenKids += [otherAsDiv.denominator.orphanCopy()]
                // send to denominator
                if let denAsMult = otherAsDiv.denominator as? MultiplicationModel {
                    newDenKids += denAsMult.list.map({ model in model.orphanCopy() })
                    newOtherSide = RationalModel(otherAsDiv.denominator, MultiplicationModel(newDenKids))
                } else {
                    newOtherSide = RationalModel(
                        otherAsDiv.numerator,
                        MultiplicationModel(newDenKids))
                }
            } else {
                // send to numerator
                if let numAsMult = otherAsDiv.numerator as? MultiplicationModel {
                    var newNumKids = [ExpressionModel]()
                    if let lcaAsMult = lca as? MultiplicationModel, !lca.selectedRanges.isEmpty {
                        let range = lcaAsMult.selectedRanges.first!.value
                        newNumKids = Array(lcaAsMult.list[range.0...range.1])
                    } else {
                        newNumKids = [lca.orphanCopy()]
                    }
                    newNumKids += numAsMult.list.map({ model in model.orphanCopy() })
                    newOtherSide = RationalModel(MultiplicationModel(newNumKids), otherAsDiv.denominator)
                } else {
                    var newNumKids = [ExpressionModel]()
                    if let lcaAsMult = lca as? MultiplicationModel {
                        if lca.selectedRanges.isEmpty {
                            newNumKids += lcaAsMult.list
                        } else {
                            let range = lcaAsMult.selectedRanges.first!.value
                            newNumKids = Array(lcaAsMult.list[range.0...range.1])
                        }
                    } else {
                        newNumKids = [lca.orphanCopy()]
                    }
                    newNumKids += [otherAsDiv.numerator.orphanCopy()]
                    newOtherSide = RationalModel(
                        MultiplicationModel(newNumKids),
                        otherAsDiv.denominator)
                }
            }
        } else {
            if inNumerator {
                // I'd like to put this in the this side code but i want to finish this before
                // working on group theory fu
                if let lcaAsMult = lca as? MultiplicationModel, !lca.selectedRanges.isEmpty {
                    let range = lcaAsMult.selectedRanges.first?.value ?? (Int.min, Int.max)
                    let selected = Array(lcaAsMult.list[range.0...range.1] /*+ [otherSide.orphanCopy()]*/)
                    newOtherSide = RationalModel(otherSide.orphanCopy(), MultiplicationModel(selected))
                } else {
                    newOtherSide = RationalModel(otherSide.orphanCopy(), lca.orphanCopy())
                }
            } else {
                if let lcaAsMult = lca as? MultiplicationModel, !lca.selectedRanges.isEmpty {
                    let range = lcaAsMult.selectedRanges.first?.value ?? (Int.min, Int.max)
                    let selected = Array(lcaAsMult.list[range.0...range.1] + [otherSide.orphanCopy()])
                    newOtherSide = RationalModel(MultiplicationModel(selected), otherSide.orphanCopy())
                } else {
                    newOtherSide = MultiplicationModel([lca.orphanCopy(), otherSide.orphanCopy()])
                }
            }
        }
        
        equals.replaceChildAt(thisSide.getChildIndex(), with: newThisSide)
        equals.replaceChildAt(otherSide.getChildIndex(), with: newOtherSide)
        
        return newExpression
    }
}
