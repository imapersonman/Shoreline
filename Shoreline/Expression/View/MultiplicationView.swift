//
//  MultiplicationView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/5/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class MultiplicationView: NAryView {
    init(list: [ExpressionView]) {
        super.init(origin: NSPoint.zero, list: list, operatorCharacter: "*")
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
