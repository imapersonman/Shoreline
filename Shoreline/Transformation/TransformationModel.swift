//
//  TransformationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/7/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class TransformationModel {
    let top: ExpressionModel
    let bottom: ExpressionModel
    var locked: Bool
    
    init(top: ExpressionModel, bottom: ExpressionModel) {
        self.top = top
        self.bottom = bottom
        self.locked = false
    }
    
    func getMatchTuple(_ selectedTree: ExpressionModel) -> (ExpressionModel, ExpressionModel)? {
        if selectedTree.matchesExpression(self.top) {
            return (self.top, self.bottom)
        } else if selectedTree.matchesExpression(self.bottom) {
            return (self.bottom, self.top)
        } else {
            return nil
        }
    }
    
    func matchesExpressionMap(_ map: [Int: [ExpressionModel]]) -> Bool {
        return false
    }
    
    func getLocked() -> Bool {
        return self.locked
    }
    
    func setLocked(_ locked: Bool) {
        self.locked = locked
    }
    
    func transformExpression(_ expression: ExpressionModel) -> ExpressionModel {
        return expression
    }
}
