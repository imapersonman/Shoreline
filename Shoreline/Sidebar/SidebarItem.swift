//
//  SidebarItem.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/9/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SidebarItem: NSCollectionViewItem {
    var expression = ExpressionModel()
    var expressionView: ExpressionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setExpression(_ expression: ExpressionModel) {
        if self.expressionView != nil {
            self.expressionView?.removeFromSuperview()
        }
        self.expression = expression
        self.expressionView = expression.asView()
        self.expressionView!.setFontSize(size: 16)
        self.expressionView!.frame.origin.x = self.view.frame.width / 2 - self.expressionView!.frame.width / 2
        self.expressionView!.frame.origin.y = self.view.frame.height / 2 - self.expressionView!.frame.height / 2
        self.view.addSubview(self.expressionView!)
    }
}
