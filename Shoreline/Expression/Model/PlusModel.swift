//
//  PlusModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PlusModel: ExpressionModel {
    var list: [ExpressionModel]
    
    init(_ list: [ExpressionModel]) {
        self.list = list
        super.init()
        
        for index in 0...self.list.count - 1 {
            self.list[index].setParent(self)
            self.list[index].setChildIndex(index)
        }
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        for model in self.list {
            model.clearSelectedRanges()
        }
    }
    
    override func orphanCopy() -> ExpressionModel {
        let model = PlusModel(self.list.map({ (child) in child.orphanCopy() }))
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func replaceWithPatternMap(_ map: [Int: ExpressionModel]) -> ExpressionModel? {
        var optionalChildren = [ExpressionModel]()
        for child in self.list {
            if let optionalChild = child.replaceWithPatternMap(map) {
                optionalChildren.append(optionalChild)
            } else {
                return nil
            }
        }
        let model = PlusModel(optionalChildren)
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func toSelectionTree() -> ExpressionModel {
        var optionalList = [ExpressionModel?](repeating: nil, count: self.list.count)
        var usedIndexes = Set<Int>()
        for (index, range) in self.selectedRanges {
            optionalList[range.0] = PatternModel(index)
            // i don't know a faster way of doing this off the top of my head
            for subIndex in range.0...range.1 {
                usedIndexes.insert(subIndex)
            }
        }
        for index in 0...self.list.count - 1 {
            if !usedIndexes.contains(index) {
                optionalList[index] = self.list[index]
            }
        }
        // basically reduce but less lame (bad explanation, no time to make good)
        var newList = [ExpressionModel]()
        for optionalExpression in optionalList {
            if let expression = optionalExpression {
                newList.append(expression)
            }
        }
        return PlusModel(newList)
    }
    
    override func applyPatternMap(_ map: [Int : [ExpressionModel]]) {
        for child in self.list {
            child.applyPatternMap(map)
        }
    }
    
    override func replaceChildAt(_ index: Int, with: ExpressionModel) {
        if index < 0 || index >= self.list.count {
            // panic
            exit(-1)
        } else {
            self.list[index] = with
            self.list[index].setChildIndex(index)
            self.list[index].setParent(self)
        }
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? PlusModel {
            // i don't think reduce short circuits and i know my speed budget sucks at this point
            if self.list.count < castExpression.list.count {
                return false
            } else {
                // substring search
                let M = castExpression.list.count
                let N = self.list.count
                for i in 0...(N - M) {
                    var j = 0
                    while j < M {
                        if !self.list[i + j].matchesExpression(castExpression.list[j]) {
                            break
                        }
                        j += 1
                    }
                    if j == M {
                        return true
                    }
                }
                return false
            }
        } else {
            return false
        }
    }
    
    override func findMatchingSubtree(_ pattern: ExpressionModel?) -> ExpressionModel? {
        // yeah I'll clean this up later stop yelling at me, please
        if pattern == nil {
            return nil
        } else if self.matchesExpression(pattern!) {
            return self
        } else {
            for child in self.list {
                if let match = child.findMatchingSubtree(pattern) {
                    return match
                }
            }
            return nil
        }
    }
    
    override func selectRange(_ index: Int, _ range: (Int, Int)) {
        // there's no range check so when things break they break.  fix later.
        if range.0 == 0 && range.1 == self.list.count - 1 {
            self.clearSelectedRanges()
            self.getParent()?.selectRange(index, (self.getChildIndex(), self.getChildIndex()))
        } else {
            var intersectedRange = false
            for (oldIndex, oldRange) in self.selectedRanges {
                if ExpressionModel.rangesIntersect(r1: oldRange, r2: range) {
                    let newRange = (min(oldRange.0, range.0), max(oldRange.1, range.1))
                    //print("INTERSECTING: \(newRange), \(oldRange)")
                    self.selectedRanges[oldIndex] = newRange
                    //self.selectedRanges.removeValue(forKey: index)
                    intersectedRange = true
                }
            }
            if !intersectedRange {
                self.selectedRanges[index] = range
            }
        }
    }
    
    override func asView() -> ExpressionView {
        let children = self.list.map({ (model: ExpressionModel) -> ExpressionView in
            return model.asView()
        })
        let view = PlusView(list: children)
        for (index, range) in self.selectedRanges {
            view.selectRange(index, range: range)
        }
        
        return view
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return self.list
    }
}
