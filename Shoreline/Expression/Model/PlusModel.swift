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
        super.init()
        
        for index in 0...self.list.count - 1 {
            self.list[index].setParent(self)
            self.list[index].setChildIndex(index)
        }
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        for model in self.list {
            model.clearSelectedRanges()
        }
    }
    
    override func selectRange(_ index: Int, _ range: (Int, Int)) {
        for (oldIndex, oldRange) in self.selectedRanges {
            var newRange = range
            if ExpressionModel.rangesIntersect(r1: oldRange, r2: newRange) {
                newRange = (min(oldRange.0, newRange.0), max(oldRange.1, newRange.1))
                self.selectedRanges[oldIndex] = newRange
            }
        }
        self.selectedRanges[index] = range
    }
    
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
    
    override func getSubExpressions() -> [ExpressionModel]? {
        return self.list
    }
}
