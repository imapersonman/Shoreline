//
//  PlusModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PlusModel: ExpressionModel {
    let list: [ExpressionModel]
    
    init(_ list: [ExpressionModel]) {
        self.list = list
        for index in 0...self.list.count - 1 {
            self.list[index].setChildIndex(index)
        }
    }
    
    override func asView() -> ExpressionView {
        let children = self.list.map({ (model: ExpressionModel) -> ExpressionView in
            return model.asView()
        })
        return PlusView(list: children)
    }
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return self.list
    }
}
