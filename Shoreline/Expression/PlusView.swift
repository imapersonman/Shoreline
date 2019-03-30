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
    var selectionBoxes = [NSBox]()
    
    init(origin: NSPoint, list: [ExpressionView]) {
        let frame = NSRect(origin: origin, size: NSSize.zero)
        super.init(frame: frame)
        self.expressions = list
        for expression in self.expressions {
            expression.setParent(self)
        }
        
        self.layoutCustom()
    }
    
    convenience init(list: [ExpressionView]) {
        self.init(origin: NSPoint.zero, list: list)
    }
    
    override func getExpressionSubviews() -> [ExpressionView]? {
        if expressions.count > 0 {
            return self.expressions
        } else {
            return [ExpressionView]?.none
        }
    }
    
    override func setSelectionIndex(_ selectionIndex: Int, rangeSelected: (Int, Int)) {
        super.setSelectionIndex(selectionIndex, rangeSelected: rangeSelected)
        if rangeSelected.0 < 0 || rangeSelected.0 >= self.expressions.count
            || rangeSelected.1 < rangeSelected.0 || rangeSelected.1 >= self.expressions.count {
            print("We're all going to die thanks to you. Great")
            exit(-1) // For now
        }
        
        var selectionFrame = NSRect(origin: self.expressions[rangeSelected.0].frame.origin, size: NSSize.zero)
        
        for index in rangeSelected.0...rangeSelected.1 {
            let view = self.expressions[index]
            if selectionFrame.height < view.frame.height {
                selectionFrame.size.height = view.frame.height
            }
            selectionFrame.size.width += view.frame.width
            if index != rangeSelected.1 - 1 {
                selectionFrame.size.width += self.plusWidth
            }
        }
        self.box.frame = selectionFrame
        
        let color = ExpressionView.getColorForSelectionIndex(selectionIndex)
        let newBox = ExpressionView.createBorderBox(color: color, frame: selectionFrame)
    }
    
    // I should override layout, but I don't want to break auto-layout just yet
    override func layoutCustom() {
        // Subviews removed implicitly
        super.layoutCustom()
        
        var currentX: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for index in 0...self.expressions.count - 1 {
            let view = self.expressions[index]
            view.setChildIndex(index)
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
    
    override func asModel() -> ExpressionModel {
        var list = [ExpressionModel]()
        if let subs = self.getExpressionSubviews() {
            for sub in subs {
                list.append(sub.asModel())
            }
        }
        let plus = PlusModel(list)
        plus.setSelectionIndex(self.getSelectionIndex())
        return plus
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
