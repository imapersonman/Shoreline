//
//  ScrollView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/8/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class HistoryView: NSView {
    static let ARBITRARY_EXPRESSION_DISTANCE: CGFloat = 20
    static let ARBITRARY_TOP_PADDING: CGFloat = 50
    
    var list: [ExpressionView]
    var fontSize: CGFloat = 0
    
    init(list: [ExpressionView]) {
        self.list = list
        super.init(frame: NSRect.zero)
        self.layoutCustom()
    }
    
    convenience init() {
        self.init(list: [ExpressionView]())
    }
    
    required init?(coder decoder: NSCoder) {
        self.list = [ExpressionView]()
        super.init(coder: decoder)
        self.layoutCustom()
    }
    
    func addExpression(_ expression: ExpressionView) {
        self.list.append(expression)
        self.layoutCustom()
    }
    
    func setExpressions(_ expressions: [ExpressionView]) {
        self.list = expressions
        self.layoutCustom()
    }
    
    func layoutCustom() {
        // uuuugghghgh
        for view in subviews {
            view.removeFromSuperview()
        }
        
        var currentY: CGFloat = 0.0
        var maxWidth: CGFloat = 0.0
        
        for expression in self.list.reversed() {
            self.addSubview(expression)
            expression.setFontSize(size: self.fontSize)
            expression.frame.origin = NSPoint(
                x: 0.0,
                y: currentY)
            currentY += expression.frame.height + HistoryView.ARBITRARY_EXPRESSION_DISTANCE
            maxWidth = max(maxWidth, expression.frame.width)
        }
        
        self.frame.size.height = currentY - HistoryView.ARBITRARY_EXPRESSION_DISTANCE
        self.frame.size.width = maxWidth
    }
    
    func setFontSize(_ fontSize: CGFloat) {
        self.fontSize = fontSize
        self.layoutCustom()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
