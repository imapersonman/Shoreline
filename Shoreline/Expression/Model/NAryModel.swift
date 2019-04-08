//
//  NAryModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/5/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class NAryModel: ExpressionModel {
    var list: [ExpressionModel]
    
    init(_ list: [ExpressionModel]) {
        self.list = list
        super.init()
        
        if list.count > 0 {
            for index in 0...self.list.count - 1 {
                self.list[index].setParent(self)
                self.list[index].setChildIndex(index)
            }
        }
    }
    
    convenience override init() {
        self.init([ExpressionModel]())
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        for model in self.list {
            model.clearSelectedRanges()
        }
    }
    
    // OVERRIDE
    override func orphanCopy() -> ExpressionModel {
        let model = self.new(self.list.map({ (child) in child.orphanCopy() }))
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    // OVERRIDE
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
        return self.new(newList)
    }
    
    override func replaceChildAt(_ index: Int, with: ExpressionModel) {
        if index < 0 || index >= self.list.count {
            // panic
            print("replaceChildAt for CommutativeNAryModel's index is out of bounds")
            exit(-1)
        } else {
            self.list[index] = with
            self.list[index].setChildIndex(index)
            self.list[index].setParent(self)
        }
    }
    
    // OVERRIDE
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? NAryModel {
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
        return NAryView(
            list: self.list.map({ (model) in model.asView() }),
            operatorCharacter: "_")
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return self.list
    }
    
    func new(_ list: [ExpressionModel]) -> NAryModel {
        return NAryModel(list)
    }
    
    func sameType(_ other: NAryModel) -> Bool {
        return type(of: other) == NAryModel.self
    }
}
