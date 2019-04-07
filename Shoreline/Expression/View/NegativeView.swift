//
//  NegativeView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/6/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class NegativeView: ExpressionView {
    let child: ExpressionView
    
    // This sort of looks like a model.  That's not good.  Fix later.
    var selectionBoxes = [Int: NSBox]()
    var selectionRanges = [Int: (Int, Int)]()
    
    init(origin: NSPoint, child: ExpressionView) {
        self.child = child
        super.init(frame: NSRect(origin: origin, size: NSSize.zero))
        
        self.addSubview(self.child)
        self.child.setParent(self)
        self.child.setChildIndex(0)
        self.layoutCustom()
    }
    
    convenience init(_ child: ExpressionView) {
        self.init(origin: NSPoint.zero, child: child)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getExpressionSubviews() -> [ExpressionView]? {
        return [self.child]
    }
    
    func createRangedSelectionFrame(range: (Int, Int)) -> NSRect {
        if range == (0, 0) {
            return self.child.frame
        } else {
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
        
        var currentX: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // code needs to be pulled out into ExpressionView
        if self.hasParenthesis {
            let leftParen = NSTextField(labelWithAttributedString: NSAttributedString(string: "("))
            leftParen.font = NSFont.systemFont(ofSize: self.fontSize)
            leftParen.sizeToFit()
            leftParen.frame.origin = NSPoint(x: currentX, y: 0)
            self.addSubview(leftParen)
            currentX += leftParen.frame.width
            maxHeight = leftParen.frame.height
        }
        
        let negative = NSTextField(labelWithAttributedString: NSAttributedString(string: "-"))
        negative.font = NSFont.systemFont(ofSize: self.fontSize)
        negative.sizeToFit()
        negative.frame.origin = NSPoint(x: currentX, y: 0.0)
        currentX += negative.frame.width
        self.addSubview(negative)
        
        self.child.setFontSize(size: self.fontSize)
        self.child.frame.origin = NSPoint(x: currentX, y: 0.0)
        self.addSubview(self.child)
        currentX += self.child.frame.width
        maxHeight = max(maxHeight, self.child.frame.height)
        
        
        if self.hasParenthesis {
            let rightParen = NSTextField(labelWithAttributedString: NSAttributedString(string: ")"))
            rightParen.font = NSFont.systemFont(ofSize: self.fontSize)
            rightParen.frame.origin = NSPoint(x: currentX, y: 0)
            rightParen.sizeToFit()
            self.addSubview(rightParen)
            currentX += rightParen.frame.width
        }
        
        self.frame.size = NSSize(width: currentX, height: maxHeight)
        
        for (index, box) in self.selectionBoxes {
            box.frame = self.createRangedSelectionFrame(range: self.selectionRanges[index]!)
            self.addSubview(box)
        }
    }
    
    override func setParent(_ parent: ExpressionView) {
        super.setParent(parent)
        if type(of: parent) != SourceView.self {
            self.hasParenthesis = true
        }
        // i should be using dirty flags but i'm tired
        self.layoutCustom()
    }
}
