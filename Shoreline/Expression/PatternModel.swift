//
//  PatternModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/24/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PatternModel: ExpressionModel {
    let patternId: Int
    
    init(_ patternId: Int) {
        self.patternId = patternId
    }
    
    override func asView() -> ExpressionView {
        return PatternView(patternId: self.patternId)
    }
}
