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
    
    var numerator: ExpressionView?
    var denominator: ExpressionView?
    var line = NSBox()
    
    init(origin: NSPoint, numerator: ExpressionView, denominator: ExpressionView) {
        self.numerator = numerator
        self.denominator = denominator
        super.init(frame: NSRect(origin: origin, size: NSSize.zero))
        
        self.addSubview(self.denominator!)
        self.addSubview(self.numerator!)
        self.numerator?.setParent(self)
        self.denominator?.setParent(self)
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
        // I like to live on the edge
        if let num = self.numerator {
            if let den = self.denominator {
                return [num, den]
            }
        }
        return [ExpressionView]?.none
    }
    
    override func layoutCustom() {
        super.layoutCustom()
        
        self.denominator?.setFontSize(size: self.fontSize)
        self.denominator?.frame.origin = NSPoint.zero
        self.addSubview(self.denominator!)
        
        self.numerator?.setFontSize(size: self.fontSize)
        self.numerator?.frame.origin = NSPoint(
            x: 0.0,
            y: self.denominator!.frame.height + RationalView.ARBITRARY_NUMERATOR_SEPARATION)
        self.addSubview(self.numerator!)
        
        let line = NSBox(
            frame: NSRect(x: 0.0,
                          y: self.denominator!.frame.height,
                          width: max(self.numerator!.frame.width, self.denominator!.frame.width),
                          height: 2.0))
        line.titlePosition = NSBox.TitlePosition.noTitle
        line.fillColor = NSColor.black
        self.addSubview(line)
        
        self.numerator!.frame.origin.x += line.frame.width / 2 - self.numerator!.frame.width / 2
        self.denominator!.frame.origin.x += line.frame.width / 2 - self.denominator!.frame.width / 2
        
        self.frame.size = NSSize(
            width: line.frame.width,
            height: self.numerator!.frame.height + self.denominator!.frame.height + RationalView.ARBITRARY_NUMERATOR_SEPARATION)
        self.box.frame.size = self.frame.size
        
        // Don't worry bout it performance doesn't matter
        self.setNeedsDisplay(self.frame)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
}
