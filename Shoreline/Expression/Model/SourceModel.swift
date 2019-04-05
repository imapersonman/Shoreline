//
//  SourceModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/1/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SourceModel: ExpressionModel {
    var child: ExpressionModel
    
    init(_ child: ExpressionModel) {
        self.child = child
        super.init()
        self.child.setParent(self)
        self.child.setChildIndex(0)
    }
    
    override func orphanCopy() -> ExpressionModel {
        let model = SourceModel(self.child.orphanCopy())
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func replaceWithPatternMap(_ map: [Int: ExpressionModel]) -> ExpressionModel? {
        if let optionalChild = self.child.replaceWithPatternMap(map) {
            return SourceModel(optionalChild)
        } else {
            return nil
        }
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? SourceModel {
            return self.child.matchesExpression(castExpression.child)
        } else {
            return false
        }
    }
    
    override func replaceChildAt(_ index: Int, with: ExpressionModel) {
        if index == 0 {
            self.child = with
            self.child.setChildIndex(0)
            self.child.setParent(self)
        } else {
            // panic
            exit(-1)
        }
    }
    
    override func replaceChildrenAt(_ index: Int, with: [ExpressionModel]) {
        if index == 0, let first = with.first {
            self.child = first
            self.child.setChildIndex(0)
            self.child.setParent(self)
        } else {
            // panic
            exit(-1)
        }
    }
    
    override func toSelectionTree() -> ExpressionModel {
        let model = SourceModel(self.child.toSelectionTree())
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func applyPatternMap(_ map: [Int : [ExpressionModel]]) {
        self.child.applyPatternMap(map)
    }
    
    override func findMatchingSubtree(_ pattern: ExpressionModel?) -> ExpressionModel? {
        if pattern == nil {
            return nil
        } else if self.matchesExpression(pattern!) {
            return self
        } else {
            return self.child.findMatchingSubtree(pattern)
        }
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        self.child.clearSelectedRanges()
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return [self.child]
    }
    
    override func selectRange(_ index: Int, _ range: (Int, Int)) {
        // a lot of this needs to change I'm ever so slightly scared
        self.selectedRanges[index] = range
    }
    
    override func asView() -> ExpressionView {
        let source = SourceView(self.child.asView())
        if let rangePair = self.selectedRanges.first {
            source.selectRange(rangePair.0, range: rangePair.1)
        }
        return source
    }
}
