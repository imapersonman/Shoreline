//
//  RationalModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class RationalModel: ExpressionModel {
    let numerator: ExpressionModel
    let denominator: ExpressionModel
    
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
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        self.numerator.clearSelectedRanges()
        self.denominator.clearSelectedRanges()
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return [self.numerator, self.denominator]
    }
}
