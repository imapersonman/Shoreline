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
            print("replaceChildAt for SourceModel's specified index is not 0")
        }
    }
    
    override func replaceChildrenAt(_ index: Int, with: [ExpressionModel]) {
        if index == 0, let first = with.first {
            self.child = first
            self.child.setChildIndex(0)
            self.child.setParent(self)
        } else {
            // panic
            print("replaceChildAt for SourceModel's specified index is not 0")
        }
    }
    
    override func toSelectionTree() -> ExpressionModel {
        let model = SourceModel(self.child.toSelectionTree())
        model.selectedRanges = self.selectedRanges
        return model
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
