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
    var hasParenthesis = false
    private var expressionParent: ExpressionView?
    private var childIndex = -1
    
    static func createBorderBox(color: NSColor, frame: NSRect) -> NSBox {
        let box = NSBox(frame: frame)
        box.borderColor = NSColor.black
        box.fillColor = NSColor.clear
        box.borderWidth = 3.0
        box.borderType = NSBorderType.lineBorder
        box.borderColor = color
        box.titlePosition = NSBox.TitlePosition.noTitle
        box.boxType = NSBox.BoxType.custom
        box.isHidden = true
        return box
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
    
    static let COLORMAP: [NSColor] = [
        NSColor(red: 207/255.0, green: 114/255.0, blue: 58/255.0, alpha: 1.0),
        NSColor(red: 163/255.0, green: 97/255.0, blue: 199/255.0, alpha: 1.0),
        NSColor(red: 113/255.0, green: 178/255.0, blue: 66/255.0, alpha: 1.0),
        NSColor(red: 197/255.0, green: 93/255.0, blue: 147/255.0, alpha: 1.0),
        NSColor(red: 82/255.0, green: 169/255.0, blue: 126/255.0, alpha: 1.0),
        NSColor(red: 203/255.0, green: 83/255.0, blue: 88/255.0, alpha: 1.0),
        NSColor(red: 101/255.0, green: 136/255.0, blue: 205/255.0, alpha: 1.0),
        NSColor(red: 161/255.0, green: 144/255.0, blue: 63/255.0, alpha: 1.0)
    ]
    
    static func getColorForSelectionIndex(_ selectionIndex: Int) -> NSColor {
        if selectionIndex == -2 {
            return NSColor.gray
        } else if selectionIndex < 0 || selectionIndex >= ExpressionView.COLORMAP.count {
            return NSColor.black
        } else {
            return ExpressionView.COLORMAP[selectionIndex]
        }
    }
    
    func selectRange(_ selectionIndex: Int, range: (Int, Int)) {
        // to be overidden
    }
    
    func setFontSize(size: CGFloat) {
        self.fontSize = size
        self.layoutCustom()
    }
    
    func asModel() -> ExpressionModel {
        return ExpressionModel()
    }
    
    func layoutCustom() {
        // This caused a bug where multiple element selection didn't work
        self.subviews.forEach({ $0.removeFromSuperview() })
        // No ewwww!!!!
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}
