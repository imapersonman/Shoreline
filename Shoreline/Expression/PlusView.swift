//
//  PlusView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/16/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PlusView: ExpressionView {
    var expressions = [ExpressionView]()
    var plusWidth: CGFloat = 0
    
    init(origin: NSPoint, list: [ExpressionView]) {
        let frame = NSRect(origin: origin, size: NSSize.zero)
        super.init(frame: frame)
        self.expressions = list
        for expression in self.expressions {
            expression.setParent(self)
        }
        
        self.layoutCustom()
    }
    
    override func getExpressionSubviews() -> [ExpressionView]? {
        if expressions.count > 0 {
            return self.expressions
        } else {
            return [ExpressionView]?.none
        }
    }
    
    // I should override layout, but I don't want to break auto-layout just yet
    override func layoutCustom() {
        // Subviews removed implicitly
        super.layoutCustom()
        
        var currentX: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for index in 0...self.expressions.count - 1 {
            let view = self.expressions[index]
            view.setFontSize(size: self.fontSize)
            view.frame.origin = NSPoint(x: currentX, y: 0)
            self.addSubview(view)
            if index != self.expressions.count - 1 {
                let plus = NSTextField(labelWithAttributedString: NSAttributedString(string: "+"))
                plus.font = NSFont.systemFont(ofSize: self.fontSize)
                plus.sizeToFit()
                self.plusWidth = plus.frame.width
                plus.frame.origin = NSPoint(x: view.frame.origin.x + view.frame.width, y: 0)
                self.addSubview(plus)
                currentX += plus.frame.width
            }
            currentX += view.frame.width
            maxHeight = max(maxHeight, view.frame.height)
        }
        
        for view in self.subviews {
            view.frame.origin.y = maxHeight / 2 - view.frame.height / 2
        }
        
        let size = NSSize(width: currentX, height: maxHeight)
        self.frame = NSRect(origin: self.frame.origin, size: size)
        self.box.frame.size = self.frame.size
        self.box.frame.origin = NSPoint.zero
        
        // Don't worry bout it performance doesn't matter
        self.setNeedsDisplay(self.frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
