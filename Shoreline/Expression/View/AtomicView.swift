//
//  AtomicView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/16/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class AtomicView: ExpressionView {
    var text = ""
    
    init(origin: NSPoint, text: String) {
        super.init(frame: NSRect(origin: origin, size: NSSize.zero))
        self.text = text
        self.layoutCustom()
    }
    
    convenience init(_ text: String) {
        self.init(origin: NSPoint.zero, text: text)
    }
    
    override func layoutCustom() {
        super.layoutCustom()
        let field = NSTextField(labelWithAttributedString: NSAttributedString(string: self.text))
        field.font = NSFont.systemFont(ofSize: self.fontSize)
        field.sizeToFit()
        self.addSubview(field)
        self.frame.size = NSSize(width: field.frame.width, height: field.frame.height)
        
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
