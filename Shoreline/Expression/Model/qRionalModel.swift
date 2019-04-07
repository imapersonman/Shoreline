//
//  RationalModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class RationalModel: ExpressionModel {
    var numerator: ExpressionModel
    var denominator: ExpressionModel
    
    init(_ numerator: ExpressionModel, _ denominator: ExpressionModel) {
        self.numerator = numerator
        self.denominator = denominator
        super.init()
        
        self.numerator.setParent(self)
        self.denominator.setParent(self)
        
        self.numerator.setChildIndex(0)
        self.denominator.setChildIndex(1)
    }
    
    override func asView() -> ExpressionView {
        let view = RationalView(numerator: self.numerator.asView(), denominator: self.denominator.asView())
        for (index, range) in self.getSelectedRanges() {
            view.selectRange(index, range: range)
        }
        return view
    }
    
    override func orphanCopy() -> ExpressionModel {
        let model = RationalModel(self.numerator.orphanCopy(), self.denominator.orphanCopy())
        model.selectedRanges = self.selectedRanges
        return model
    }
    
    override func replaceChildAt(_ index: Int, with: ExpressionModel) {
        switch index {
        case 0:
            self.numerator = with
            self.numerator.setChildIndex(0)
            self.numerator.setParent(self)
        case 1:
            self.denominator = with
            self.denominator.setChildIndex(1)
            self.denominator.setParent(self)
        default:
            // panic
            print("replaceChildAt for RationalModel's specified index is not 0 or 1")
            exit(-1)
        }
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? RationalModel {
            return self.numerator.matchesExpression(castExpression.numerator)
                && self.denominator.matchesExpression(castExpression.denominator)
        } else {
            return false
        }
    }
    
    override func toSelectionTree() -> ExpressionModel {
        // according to the logic of ExpressionModel.selectRange, there should only be one
        // range in a RationalModel.  there can be more in IrrationalModels (don't worry i
        // also hate myself for that).
        if let (index, range) = self.selectedRanges.first {
            switch range {
            case (0, 0):
                // numerator is selected
                return RationalModel(PatternModel(index), self.denominator.orphanCopy())
            case (1, 1):
                // denominator is selected
                return RationalModel(self.numerator.orphanCopy(), PatternModel(index))
            default:
                // there shouldn't be any other options
                return RationalModel(self.numerator.orphanCopy(), self.denominator.orphanCopy())
            }
        } else {
            return self.orphanCopy()
            // print("toSelectionTree for RationalModel's ranges are not correct")
            // exit(-1)
        }
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        self.numerator.clearSelectedRanges()
        self.denominator.clearSelectedRanges()
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return [self.numerator, self.denominator]
    }
}
