//
//  MultiplicationModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/5/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class MultiplicationModel: NAryModel {
    override func asView() -> ExpressionView {
        let children = self.list.map({ (model: ExpressionModel) -> ExpressionView in
            return model.asView()
        })
        let view = MultiplicationView(list: children)
        for (index, range) in self.selectedRanges {
            view.selectRange(index, range: range)
        }
        
        return view
    }
    
    override func new(_ list: [ExpressionModel]) -> NAryModel {
        return MultiplicationModel(list)
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        if let castExpression = expression as? MultiplicationModel {
            return super.matchesExpression(castExpression)
        } else {
            return false
        }
    }
    
    override func sameType(_ other: NAryModel) -> Bool {
        return type(of: other) == MultiplicationModel.self
    }
}
