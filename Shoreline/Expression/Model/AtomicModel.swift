//
//  AtomicModel.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/23/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class AtomicModel: ExpressionModel {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    override func asView() -> ExpressionView {
        return AtomicView(self.text)
    }
}
