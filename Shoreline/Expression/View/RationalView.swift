//
//  RationalView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/16/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class RationalView: ExpressionView {
    static let ARBITRARY_NUMERATOR_SEPARATION: CGFloat = 5.0;
    
    let numerator: ExpressionView
    let denominator: ExpressionView
    var line = NSBox()
    
    // This sort of looks like a model.  That's not good.  Fix later.
    var selectionBoxes = [Int: NSBox]()
    var selectionRanges = [Int: (Int, Int)]()
    
    init(origin: NSPoint, numerator: ExpressionView, denominator: ExpressionView) {
        self.numerator = numerator
        self.denominator = denominator
        super.init(frame: NSRect(origin: origin, size: NSSize.zero))
        
        self.addSubview(self.denominator)
        self.addSubview(self.numerator)
        self.numerator.setParent(self)
        self.numerator.setChildIndex(0)
        self.denominator.setParent(self)
        self.denominator.setChildIndex(1)
        self.addSubview(line)
        self.layoutCustom()
    }
    
    convenience init(numerator: ExpressionView, denominator: ExpressionView) {
        self.init(origin: NSPoint.zero, numerator: numerator, denominator: denominator)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getExpressionSubviews() -> [ExpressionView]? {
        return [self.numerator, self.denominator]
    }
    
    func createRangedSelectionFrame(range: (Int, Int)) -> NSRect {
        switch range {
        case (0, 0):
            // numerator view
            return self.numerator.frame
        case (1, 1):
            // denominator view
            return self.denominator.frame
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
        
        self.denominator.setFontSize(size: self.fontSize)
        self.denominator.frame.origin = NSPoint.zero
        self.addSubview(self.denominator)
        
        self.numerator.setFontSize(size: self.fontSize)
        self.numerator.frame.origin = NSPoint(
            x: 0.0,
            y: self.denominator.frame.height + RationalView.ARBITRARY_NUMERATOR_SEPARATION)
        self.addSubview(self.numerator)
        
        let line = NSBox(
            frame: NSRect(x: 0.0,
                          y: self.denominator.frame.height,
                          width: max(self.numerator.frame.width, self.denominator.frame.width),
                          height: 4.0))
        line.titlePosition = NSBox.TitlePosition.noTitle
        line.fillColor = NSColor.black
        line.boxType = NSBox.BoxType.custom
        self.addSubview(line)
        
        self.numerator.frame.origin.x += line.frame.width / 2 - self.numerator.frame.width / 2
        self.denominator.frame.origin.x += line.frame.width / 2 - self.denominator.frame.width / 2
        
        self.frame.size = NSSize(
            width: line.frame.width,
            height: self.numerator.frame.height + self.denominator.frame.height + RationalView.ARBITRARY_NUMERATOR_SEPARATION)
        
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
