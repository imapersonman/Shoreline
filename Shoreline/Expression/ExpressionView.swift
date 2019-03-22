//
//  ExpressionView.swift
//  Shoreline
//
//  Created by Koissi Adjorlolo on 3/16/19.
//  Copyright © 2019 Koissi Adjorlolo. All rights reserved.
//

import Cocoa

class ExpressionView: NSView {
    var fontSize: CGFloat = 12
    var box = NSBox(frame: NSRect.zero)
    private var expressionParent: ExpressionView?
    private var selected = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //self.wantsLayer = true
        //self.layer?.borderWidth = 2.0
        //self.layer?.cornerRadius = 10.0
        
        self.box.borderColor = NSColor.black
        self.box.fillColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.box.borderWidth = 1.0
        self.box.borderType = NSBorderType.lineBorder
        self.box.borderColor = NSColor.black
        self.box.titlePosition = NSBox.TitlePosition.noTitle
        self.box.boxType = NSBox.BoxType.custom
        self.box.isHidden = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getExpressionSubviews() -> [ExpressionView]? {
        // Should be overriden
        return [ExpressionView]?.none
    }
    
    func setParent(_ parent: ExpressionView) {
        self.expressionParent = parent
    }
    
    func getParent() -> ExpressionView? {
        return self.expressionParent
    }
    
    func setSelected(_ selected: Bool) {
        self.selected = selected
        self.box.isHidden = !self.selected
    }
    
    func getSelected() -> Bool {
        return self.selected
    }
    
    func setFontSize(size: CGFloat) {
        self.fontSize = size
        self.layoutCustom()
    }
    
    func layoutCustom() {
        // Should be overriden
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.addSubview(self.box)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
