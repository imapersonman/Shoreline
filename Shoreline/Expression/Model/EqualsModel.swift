//
//  EqualsModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/5/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class EqualsModel: ExpressionModel {
    var left = ExpressionModel()
    var right = ExpressionModel()
    
    init(_ left: ExpressionModel, _ right: ExpressionModel) {
        self.left = left
        self.right = right
        super.init()
        
        self.left.setParent(self)
        self.left.setChildIndex(0)
        self.right.setParent(self)
        self.right.setChildIndex(1)
    }
    
    override func asView() -> ExpressionView {
        let view = EqualsView(left: self.left.asView(), right: self.right.asView())
        for (index, range) in self.getSelectedRanges() {
            view.selectRange(index, range: range)
        }
        return view
    }
    
    override func orphanCopy() -> ExpressionModel {
        let model = EqualsModel(self.left.orphanCopy(), self.right.orphanCopy())
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func replaceChildAt(_ index: Int, with: ExpressionModel) {
        switch index {
        case 0:
            self.left = with
            self.left.setChildIndex(0)
            self.left.setParent(self)
        case 1:
            self.right = with
            self.right.setChildIndex(1)
            self.right.setParent(self)
        default:
            // panic
            print("replaceChildAt for EqualsModel's specified index is not 0 or 1")
            exit(-1)
        }
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? EqualsModel {
            return self.left.matchesExpression(castExpression.left)
                && self.right.matchesExpression(castExpression.right)
        } else {
            return false
        }
    }
    
    override func toSelectionTree() -> ExpressionModel {
        // according to the logic of ExpressionModel.selectRange, there should only be one
        // range in a RationalModel.  there can be more in IrrationalModels (don't worry i
        // also hate myself for that).
        var left = self.left.orphanCopy()
        var right = self.right.orphanCopy()
        for (index, range) in self.selectedRanges {
            if range == (0, 0) {
                left = PatternModel(index)
            } else if range == (1, 1) {
                right = PatternModel(index)
            }
        }
        return EqualsModel(left, right)
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        self.left.clearSelectedRanges()
        self.right.clearSelectedRanges()
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return [self.left, self.right]
    }
}
