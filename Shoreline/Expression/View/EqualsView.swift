//
//  EqualsView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/5/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class EqualsView: ExpressionView {
    let left: ExpressionView
    let right: ExpressionView
    var equals = NSBox()
    
    // This sort of looks like a model.  That's not good.  Fix later.
    var selectionBoxes = [Int: NSBox]()
    var selectionRanges = [Int: (Int, Int)]()
    
    init(origin: NSPoint, left: ExpressionView, right: ExpressionView) {
        self.left = left
        self.right = right
        super.init(frame: NSRect(origin: origin, size: NSSize.zero))
        
        self.addSubview(self.left)
        self.addSubview(self.right)
        self.left.setParent(self)
        self.left.setChildIndex(0)
        self.right.setParent(self)
        self.right.setChildIndex(1)
        self.addSubview(equals)
        self.layoutCustom()
    }
    
    convenience init(left: ExpressionView, right: ExpressionView) {
        self.init(origin: NSPoint.zero, left: left, right: right)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getExpressionSubviews() -> [ExpressionView]? {
        return [self.left, self.right]
    }
    
    func createRangedSelectionFrame(range: (Int, Int)) -> NSRect {
        switch range {
        case (0, 0):
            // numerator view
            return self.left.frame
        case (1, 1):
            // denominator view
            return self.right.frame
        case (0, 1):
            // numerator and denominator view
            return self.frame
        default:
            print("this selection doesn't make any sense for a RationalView")
            return NSRect.zero
        }
    }
    
    override func selectRange(_ selectionIndex: Int, range: (Int, Int)) {
        super.selectRange(selectionIndex, range: range)
        if range.0 < 0 || range.0 > 1 || range.1 < 0 || range.1 > 1 {
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
    
    override func layoutCustom() {
        super.layoutCustom()
        
        self.left.setFontSize(size: self.fontSize)
        self.left.frame.origin = NSPoint.zero
        self.addSubview(self.left)
        
        let equals = NSTextField(labelWithAttributedString: NSAttributedString(string: "="))
        equals.font = NSFont.systemFont(ofSize: self.fontSize)
        equals.sizeToFit()
        equals.frame.origin = NSPoint(x: self.left.frame.width, y: 0.0)
        self.addSubview(equals)
        
        self.right.setFontSize(size: self.fontSize)
        self.right.frame.origin = NSPoint(
            x: self.left.frame.width + equals.frame.width,
            y: 0.0)
        self.addSubview(self.right)
        
        self.frame.size = NSSize(
            width: self.left.frame.width + equals.frame.width + self.right.frame.width,
            height: max(self.left.frame.height, self.right.frame.height))
        
        for view in self.subviews {
            view.frame.origin.y = self.frame.height / 2 - view.frame.height / 2
        }
        
        for (index, box) in self.selectionBoxes {
            box.frame = self.createRangedSelectionFrame(range: self.selectionRanges[index]!)
            self.addSubview(box)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
}
