//
//  ExpressionModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ExpressionModel: NSObject {
    private var childIndex = -1
    private var parent: ExpressionModel?
    var selectedRanges = [Int: (Int, Int)]()
    
    static func rangesIntersect(r1: (Int, Int), r2: (Int, Int)) -> Bool {
        return r1.0 < r2.1 && r2.0 < r1.1
    }
    
    /**
     * lowestCommonAncestor: [ExpressionView] -> ExpressionView?
     *
     * Returns the lowest common ancestor of all the ExpressionView's in the given list.
     */
    static func lowestCommonAncestor(_ expressions: Set<ExpressionModel>) -> ExpressionModel? {
        var visitedNodeCount = [ExpressionModel : Int]()
        
        for expression in expressions {
            var current = Optional(expression)
            while current != nil {
                if visitedNodeCount[current!] == nil {
                    visitedNodeCount[current!] = 1
                } else {
                    visitedNodeCount.updateValue(visitedNodeCount[current!]! + 1, forKey: current!)
                }
                if visitedNodeCount[current!] == expressions.count {
                    return current!
                }
                current = current?.getParent()
            }
        }
        
        return nil
    }
    
    func getChildIndex() -> Int {
        return self.childIndex
    }
    
    func setChildIndex(_ childIndex: Int) {
        self.childIndex = childIndex
    }
    
    func clearSelectedRanges() {
        self.selectedRanges.removeAll()
    }
    
    func selectRange(_ index: Int, _ range: (Int, Int)) {
        let subExpressions = self.getSubExpressions() ?? [ExpressionModel]()
        if range.0 == 0 && range.1 == subExpressions.count - 1 {
            self.clearSelectedRanges()
            self.getParent()?.selectRange(index, (self.getChildIndex(), self.getChildIndex()))
        } else if index == -1 {
            self.clearSelectedRanges()
        } else {
            self.selectedRanges[index] = range
        }
    }
    
    func orphanCopy() -> ExpressionModel {
        return ExpressionModel()
    }
    
    func replaceWithPatternMap(_ map: [Int: ExpressionModel]) -> ExpressionModel? {
        return nil
    }
    
    
    func createPatternMap(_ map: [Int: [ExpressionModel]] = [:]) -> [Int: [ExpressionModel]] {
        var updateMap = [Int: [ExpressionModel]]()
        let children = self.getSubExpressions() ?? [ExpressionModel]()
        for (index, range) in self.selectedRanges {
            // there need to be checks for the range, but everything breaking is preferred
            // for now
            if range.0 == range.1 {
                updateMap[index] = [children[range.0]]
            } else {
                let arr = updateMap[index] ?? [ExpressionModel]()
                updateMap[index] = arr
                updateMap[index]?.append(contentsOf: children[range.0...range.1])
            }
        }
        for child in children {
            updateMap = child.createPatternMap(updateMap)
        }
        // prioritize entries in map
        updateMap.merge(map, uniquingKeysWith: { (_, current) in current })
        return updateMap
    }
    
    func applyPatternMap(_ map: [Int: [ExpressionModel]]) {
    }
    
    func replaceChildAt(_ index: Int, with: ExpressionModel) {
    }
    
    func replaceChildrenAt(_ index: Int, with: [ExpressionModel]){
    }
    
    func toSelectionTree() -> ExpressionModel {
        return self.orphanCopy()
    }
    
    func matchesExpression(_ expression: ExpressionModel) -> Bool {
        return false
    }
    
    func findMatchingSubtree(_ pattern: ExpressionModel?) -> ExpressionModel? {
        return nil
    }
    
    func getSelectedRanges() -> [Int: (Int, Int)] {
        return self.selectedRanges
    }
    
    func getSubExpressions() -> [ExpressionModel]? {
        return nil
    }
    
    func getParent() -> ExpressionModel? {
        return self.parent
    }
    
    func setParent(_ parent: ExpressionModel) {
        self.parent = parent
    }
    
    func asView() -> ExpressionView {
        return ExpressionView()
    }
}
