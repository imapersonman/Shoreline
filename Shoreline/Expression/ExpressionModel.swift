//
//  ExpressionModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ExpressionModel: NSObject {
    private var selected = false
    private var selectionIndex = -1
    private var childIndex = -1
    private var rangeSelected = (0, 0)
    
    func getSelected() -> Bool {
        return self.selected
    }
    
    func getChildIndex() -> Int {
        return self.childIndex
    }
    
    func setChildIndex(_ childIndex: Int) {
        self.childIndex = childIndex
    }
    
    func getSelectionIndex() -> Int {
        return self.selectionIndex
    }
    
    func setSelected(_ selected: Bool) {
        self.selected = selected
    }
    
    func setSelectionIndex(_ selectionIndex: Int) {
        self.selectionIndex = selectionIndex
    }
    
    func setSelectionIndex(_ selectionIndex: Int, rangeSelected: (Int, Int)) {
        self.setSelectionIndex(selectionIndex)
        self.rangeSelected = rangeSelected
    }
    
    func getRangeSelected() -> (Int, Int) {
        return self.rangeSelected
    }
    
    func getSubExpressions() -> [ExpressionModel]? {
        return nil
    }
    
    func asView() -> ExpressionView {
        return ExpressionView()
    }
}
