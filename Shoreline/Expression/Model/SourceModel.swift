//
//  SourceModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/1/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SourceModel: ExpressionModel {
    let child: ExpressionModel
    
    init(_ child: ExpressionModel) {
        self.child = child
    }
    
    override func clearSelectedRanges() {
        super.clearSelectedRanges()
        self.child.clearSelectedRanges()
    }
    
    override func asView() -> ExpressionView {
        return self.child.asView()
    }
}
