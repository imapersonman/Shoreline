//
//  ExpressionModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ExpressionModel: NSObject {
    private var childIndex = -1
    private var parent: ExpressionModel?
    var selectedRanges = [Int: (Int, Int)]()
    
    static func rangesIntersect(r1: (Int, Int), r2: (Int, Int)) -> Bool {
        return r1.0 < r2.1 && r2.0 < r1.1
    }
    
    func getChildIndex() -> Int {
        return self.childIndex
    }
    
    func setChildIndex(_ childIndex: Int) {
        self.childIndex = childIndex
    }
    
    func clearSelectedRanges() {
        self.selectedRanges.removeAll()
    }
    
    func selectRange(_ index: Int, _ range: (Int, Int)) {
        if index != -1 {
            self.clearSelectedRanges()
        }
        self.selectedRanges[index] = range
    }
    
    func getSelectedRanges() -> [Int: (Int, Int)] {
        return self.selectedRanges
    }
    
    func getSubExpressions() -> [ExpressionModel]? {
        return nil
    }
    
    func getParent() -> ExpressionModel? {
        return self.parent
    }
    
    func setParent(_ parent: ExpressionModel) {
        self.parent = parent
    }
    
    func asView() -> ExpressionView {
        return ExpressionView()
    }
}
