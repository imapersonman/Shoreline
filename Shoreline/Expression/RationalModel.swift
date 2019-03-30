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
        
        self.numerator.setChildIndex(0)
        self.denominator.setChildIndex(1)
    }
    
    override func asView() -> ExpressionView {
        return RationalView(numerator: self.numerator.asView(), denominator: self.denominator.asView())
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return [self.numerator, self.denominator]
    }
}
