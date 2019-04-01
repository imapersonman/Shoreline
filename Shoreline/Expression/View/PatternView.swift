//
//  PatternView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/24/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class PatternView: ExpressionView {
    var backgroundBox: NSBox
    
    init(frame: NSRect, patternId: Int) {
        self.backgroundBox = NSBox(frame: NSRect(origin: NSPoint.zero, size: frame.size))
        super.init(frame: frame)
        self.backgroundBox.boxType = NSBox.BoxType.custom
        self.backgroundBox.fillColor = NSColor.clear
        self.backgroundBox.borderWidth = 4.0
        self.backgroundBox.borderColor = ExpressionView.getColorForSelectionIndex(patternId)
        self.backgroundBox.isHidden = false
    }
    
    override func layoutCustom() {
        super.layoutCustom()
        // There is a faster (performance-wise) way of doing this but I'm a computer science student
        // and refuse to follow any practice that will make my life easier in the long term if it
        // means sacrificing my short-term ability to get distracted and do something else.
        let field = NSTextField(labelWithAttributedString: NSAttributedString(string: "M"))
        field.font = NSFont.systemFont(ofSize: self.fontSize)
        field.sizeToFit()
        self.frame.size = NSSize(width: field.frame.width, height: field.frame.height)
        self.backgroundBox.frame.size = self.frame.size
        // totes arb
        self.backgroundBox.borderWidth = self.fontSize / 10.0
        self.addSubview(self.backgroundBox)
        
        // Don't worry bout it performance doesn't matter
        self.setNeedsDisplay(self.frame)
    }
    
    convenience init(patternId: Int) {
        self.init(frame: NSRect.zero, patternId: patternId)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
