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
    private var selectionIndex = -1
    private var childIndex = -1
    private var rangeSelected = (0, 0)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //self.wantsLayer = true
        //self.layer?.borderWidth = 2.0
        //self.layer?.cornerRadius = 10.0
        
        self.box = ExpressionView.createBorderBox(color: NSColor.black, frame: frame)
    }
    
    static func createBorderBox(color: NSColor, frame: NSRect) -> NSBox {
        let box = NSBox(frame: frame)
        box.borderColor = NSColor.black
        box.fillColor = NSColor.clear
        box.borderWidth = 1.0
        box.borderType = NSBorderType.lineBorder
        box.borderColor = NSColor.black
        box.titlePosition = NSBox.TitlePosition.noTitle
        box.boxType = NSBox.BoxType.custom
        box.isHidden = true
        return box
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
    
    func getChildIndex() -> Int {
        return self.childIndex
    }
    
    func setChildIndex(_ childIndex: Int) {
        self.childIndex = childIndex
    }
    
    func setSelectionIndex(_ selectionIndex: Int) {
        self.selectionIndex = selectionIndex
        self.box.isHidden = selectionIndex == -1
        self.box.borderColor = ExpressionView.getColorForSelectionIndex(selectionIndex)
    }
    
    static func getColorForSelectionIndex(_ selectionIndex: Int) -> NSColor {
        switch (selectionIndex) {
        case 0:
            return NSColor.red
        case 1:
            return NSColor.blue
        case 2:
            return NSColor.green
        default:
            return NSColor.black
        }
    }
    
    func setSelectionIndex(_ selectionIndex: Int, rangeSelected: (Int, Int)) {
        self.setSelectionIndex(selectionIndex)
        self.rangeSelected = rangeSelected
    }
    
    func getSelectionIndex() -> Int {
        return self.selectionIndex
    }
    
    func setFontSize(size: CGFloat) {
        self.fontSize = size
        self.layoutCustom()
    }
    
    func asModel() -> ExpressionModel {
        return ExpressionModel()
    }
    
    func layoutCustom() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.addSubview(self.box)
        // No ewwww!!!!
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
