//
//  SourceView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 4/2/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class SourceView: ExpressionView {
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
        
        self.child.setFontSize(size: self.fontSize)
        self.addSubview(self.child)
        self.child.setFontSize(size: self.fontSize)
        // I don't think this is important but I'll keep it for now
        self.child.frame.origin = NSPoint.zero
        self.addSubview(self.child)
        
        self.frame.size = self.child.frame.size
        
        for (index, box) in self.selectionBoxes {
            box.frame = self.createRangedSelectionFrame(range: self.selectionRanges[index]!)
            self.addSubview(box)
        }
    }
    
}
