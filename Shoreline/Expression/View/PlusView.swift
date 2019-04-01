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
    // This sort of looks like a model.  That's not good.  Fix later.
    var selectionBoxes = [Int: NSBox]()
    var selectionRanges = [Int: (Int, Int)]()
    
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
    
    override func selectRange(_ selectionIndex: Int, range: (Int, Int)) {
        super.selectRange(selectionIndex, range: range)
        if range.0 < 0 || range.0 >= self.expressions.count
            || range.1 < range.0 || range.1 >= self.expressions.count {
            print("We're all going to die thanks to you. Great")
            exit(-1) // For now
        }
        
        let frame = self.createRangedSelectionFrame(range: range)
        let color = ExpressionView.getColorForSelectionIndex(selectionIndex)
        let newBox = ExpressionView.createBorderBox(color: color, frame: frame)
        newBox.isHidden = false
        self.selectionBoxes[selectionIndex] = newBox
        self.selectionRanges[selectionIndex] = range
        self.addSubview(newBox)
    }
    
    func createRangedSelectionFrame(range: (Int, Int)) -> NSRect {
        // If the range is wrong I'm going to break things because time is not a thing
        var frame = NSRect(origin: self.expressions[range.0].frame.origin, size: NSSize.zero)
        for index in range.0...range.1 {
            let view = self.expressions[index]
            if frame.height < view.frame.height {
                frame.size.height = view.frame.height
            }
            frame.size.width += view.frame.width
            if index != range.1 - 1 && range.0 != range.1 {
                frame.size.width += self.plusWidth
            }
        }
        return frame
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
        
        self.frame.size = NSSize(width: currentX, height: maxHeight)
        
        for view in self.subviews {
            view.frame.origin.y = maxHeight / 2 - view.frame.height / 2
        }
        
        for (index, box) in self.selectionBoxes {
            box.frame = self.createRangedSelectionFrame(range: self.selectionRanges[index]!)
            self.addSubview(box)
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
