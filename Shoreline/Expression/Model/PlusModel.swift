//
//  PlusModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PlusModel: NAryModel {
    override func asView() -> ExpressionView {
        let children = self.list.map({ (model: ExpressionModel) -> ExpressionView in
            return model.asView()
        })
        let view = PlusView(list: children)
        for (index, range) in self.selectedRanges {
            view.selectRange(index, range: range)
        }
        
        return view
    }
    
    override func new(_ list: [ExpressionModel]) -> NAryModel {
        return PlusModel(list)
    }
    
    override func matchesExpression(_ expression: ExpressionModel) -> Bool {
        // Uuuuggghhhhhh
        if let castExpression = expression as? PlusModel {
            return super.matchesExpression(castExpression)
        } else {
            return false
        }
    }
    
    override func sameType(_ other: NAryModel) -> Bool {
        return type(of: other) == PlusModel.self
    }
}
